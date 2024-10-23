namespace DarajaBC.DarajaBC;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 50101 "General Ledger Setup Ext" extends "General Ledger Setup"
{
    layout{
        addlast(General)
        {
            field("Consumer Key";Rec."Consumer Key")
            {
                ApplicationArea = All;
            }
            field("Consumer Secret";Rec."Consumer Secret")
            {
                ApplicationArea = All;
            }
            field("Conversation Ids";Rec."Conversation Ids")
            {
                ApplicationArea = All;
            }
            field("Short Code";Rec."Short Code")
            {
                ApplicationArea = All;
            }
            field("Callback URL";Rec."Callback URL")
            {
                ApplicationArea = All;
            }
        }
    }
}
