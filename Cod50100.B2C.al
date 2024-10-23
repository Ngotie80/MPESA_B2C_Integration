namespace DarajaBC.DarajaBC;
using System.Text;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 50100 B2C
{
    trigger OnRun()
    begin
       
    end;

    Procedure GetAccessToken(): Text
    Var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        httprequest: HttpRequestMessage;
        RequestMessage: HttpRequestMessage;
        ResponseContent: Text;
        Content: HttpContent;
        ResponseJson: JsonObject;
        AccessToken: Text;
        url: Text;
        Response: Text;
        ResultObj: JsonObject;
        ResultJtoken: JsonToken;
        ConsumerKey:Text;ConsumerSecret:Text;
        Base64Convert: Codeunit "Base64 Convert";
        GeneralSetup: Record "General Ledger Setup";
    begin
        Clear(Content);
        url := '';
        Clear(Client);
        Clear(ResponseMessage);
        url := 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';
        GeneralSetup.Get();
        Client.DefaultRequestHeaders.Add('Authorization',  'Basic ' + Base64Convert.ToBase64(GeneralSetup."Consumer Key" + ':' + GeneralSetup."Consumer Secret"));
        if Client.Get(url,ResponseMessage) then begin
                ResponseMessage.Content.ReadAs(Response);
            if ResponseMessage.IsSuccessStatusCode = false then
                Error(Response);
            Clear(ResultObj);
            ResultObj.ReadFrom(Response);
            ResultObj.get('access_token', ResultJtoken);
            Response := ResultJtoken.AsValue().AsText();
            exit(Response);
        end;
    end;

    Procedure B2C(Recepient: Text; Amount: Decimal):Text
    var
    url: Text;
     JsonObj: JsonObject;
        HttpClient: HttpClient;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        JsonResponse: JsonObject;
        IsSucces: Boolean;
        JToken: JsonToken;
        ResponseText: Text;
        Client: HttpClient;
        Contents: HttpContent;
        Response: Text;
        ResultJtoken: JsonToken;
        ResultObj: JsonObject;
        httprequest: HttpRequestMessage;
        ContentText: Text;
        AccessToken: Text;
        Logs: Record "B2C Log Entries";
        ConversationId: Text;
        GeneralLedgerSetup: Record "General Ledger Setup";
        NoSeries: Codeunit "No. Series";
        OriginatorConversationId :Text;
        CallBackUrl: Text;
    begin
        AccessToken :='';
        OriginatorConversationId:= '';
        CallBackUrl :='';
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Conversation Ids");
        GeneralLedgerSetup.TestField("CallBack Url");
        OriginatorConversationId:= NoSeries.GetNextNo(GeneralLedgerSetup."Conversation Ids");
        CallBackUrl := GeneralLedgerSetup."CallBack Url";
        url := '';
        Clear(JsonObj);
        url:= 'https://sandbox.safaricom.co.ke/mpesa/b2c/v3/paymentrequest';
        JsonObj.Add('OriginatorConversationID',OriginatorConversationId);
            JsonObj.Add('InitiatorName', 'bettKelly');
            AccessToken := GetAccessToken();
            JsonObj.Add('SecurityCredential',AccessToken);
            JsonObj.Add('CommandID', 'BusinessPayment');
            jsonobj.Add('Amount', Amount);
            jsonobj.Add('PartyA', GeneralLedgerSetup."Short Code");
            jsonobj.Add('PartyB', Recepient);
            jsonobj.Add('Remarks', 'Payment');
            jsonobj.Add('QueueTimeOutURL', 'https://sandbox.safaricom.co.ke/mpesa/b2cresults/v1/submit');
            jsonobj.Add('ResultURL', CallBackUrl);
            jsonobj.Add('Occasion', 'Payment');
            JsonObj.WriteTo(ContentText);
            Contents.Clear();
            Contents.WriteFrom(ContentText);
            Contents.GetHeaders(Headers);
            Headers.Remove('Content-Type');
            Headers.Remove('Charset');
            Headers.Add('Content-Type', 'application/json');
            httpRequest.GetHeaders(Headers);
            httpRequest.Content(Contents);
            httpRequest.Method('POST');
            client.Clear();
            Client.SetBaseAddress(url);
            Client.DefaultRequestHeaders.Add('Charset', 'utf-8');
            Client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);
            if Client.Post(url, Contents, ResponseMessage) then
                ResponseMessage.Content.ReadAs(Response);
            if ResponseMessage.IsSuccessStatusCode = false then begin
                Error(Response);
            end;
            Clear(ResultObj);
            ResultObj.ReadFrom(Response);
            if ResultObj.get('ConversationID', ResultJtoken) then begin
                Logs.Init();
               ConversationId:= ResultJtoken.AsValue().AsText();
                logs."Entry No." := Logs.GetLastEntryNo +1;
                Logs."Conversation ID" := ConversationId;
                Logs."OriginatorConversation Id" := OriginatorConversationId;
                Logs.Insert(true);
            end; 
            ProccessCallBackResponse(CallBackUrl,ConversationId);  
            Message(Response);
            exit(ConversationId);
    end;

    Procedure ProccessCallBackResponse(CallBackUrl:text;ConversationID:Text):Text
    var
    JsonObj: JsonObject;
        HttpClient: HttpClient;
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        JsonResponse: JsonObject;
        Client: HttpClient;
        Logs: Record "B2C Log Entries";
        Response:Text;
        ResultJtoken: JsonToken;
        ResultObj: JsonObject;
        ResultParam: JsonObject;
        ResultArray: JsonArray;
        ParamJtoken: JsonToken;
        TransactionAmount: Decimal;
        TransactionReceipt: Text;
    begin
        Clear(JsonObj);
        Clear(Client);
        Clear(ResponseMessage);
        Clear(RequestMessage);
        Clear(RequestContent);
        Clear(JsonResponse);
        Clear(Response);
        if Client.Post(CallBackUrl, RequestContent, ResponseMessage) then begin
              ResponseMessage.Content.ReadAs(Response);
            if ResponseMessage.IsSuccessStatusCode = false then begin
                Error(Response);
            end;
            ResultObj.ReadFrom(Response);
             Logs.Reset();
            logs.SetRange("Conversation ID",ConversationID);
            if Logs.FindFirst() then begin
             if ResultObj.Get('ResultParameters', ResultJtoken) then begin
                    ResultArray := ResultJtoken.AsArray();
                    if ResultArray.Get(1,ParamJtoken) then
                    TransactionReceipt:= ParamJtoken.AsValue().AsText();
                    Logs."Transaction Receipt" := TransactionReceipt;
                    if ResultArray.Get(0,ParamJtoken) then
                    TransactionAmount := ParamJtoken.AsValue().AsDecimal();
                    if ResultArray.Get(5,ParamJtoken) then
                    Logs."Transaction Date Time" := ParamJtoken.AsValue().AsDateTime();
                      if ResultArray.Get(4,ParamJtoken) then
                    Logs.ReceiverPartyPublicName := ParamJtoken.AsValue().AsText();
                end;
                if ResultObj.Get('TransactionID', ResultJtoken) then
                Logs."Transaction Id" := ResultJtoken.AsValue().AsText();
                Logs."Transaction Amount " := TransactionAmount;
                Logs.Modify();
            end;
        end;
    end;
}
