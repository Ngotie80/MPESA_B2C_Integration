namespace DarajaBC.DarajaBC;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;

tableextension 50100 "General Ledger Setup Ext" extends "General Ledger Setup"
{
    fields
    {
        field(50100; "Consumer Key"; Text[150])
        {
            Caption = 'Consumer Key';
            DataClassification = ToBeClassified;
        }
        field(50101; "Consumer Secret"; Text[150])
        {
            Caption = 'Consumer Secret';
            DataClassification = ToBeClassified;
        }
        field(50102; "Conversation Ids"; Code[20])
        {
           TableRelation = "No. Series";
        }
        field(50103; "Short Code"; Code[10])
        {
            
        }
        field(50104; "Callback URL"; Text[150])
        {
            DataClassification = ToBeClassified;
        }
    }
}
