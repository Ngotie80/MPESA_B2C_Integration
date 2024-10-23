table 50100 "B2C Log Entries"
{
    Caption = 'B2C Log Entries';
    
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Conversation ID"; Text[150])
        {
            Caption = 'Conversation ID';
        }
        field(3; "OriginatorConversation Id"; Text[150])
        {
            Caption = 'OriginatorConversation Id';
        }
        field(4; "Transaction Id"; Text[150])
        {
            Caption = 'Transaction Id';
        }
        field(5; ReceiverPartyPublicName; Text[100])
        {
            Caption = 'ReceiverPartyPublicName';
        }
        field(6; "Transaction Amount "; Decimal)
        {
            
        }
        field(7; "Transaction Date Time"; DateTime)
        {
            
        }
        field(8; "Transaction Receipt"; Text[150])
        {
            
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;
    trigger OnDelete()
    begin
        error('You cannot delete this document');
    end;
}
