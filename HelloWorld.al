// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

namespace DefaultPublisher.DarajaB2C;

using Microsoft.Sales.Customer;
using DarajaBC.DarajaBC;

pageextension 50100 CustomerListExt extends "Customer List"
{
   layout{
    
   }
   actions{
    addfirst("&Customer")
    {
        action(DarajaB2C)
        {
        ApplicationArea = All;
        Caption = 'Daraja B2C';
        Image = Payment;
        Promoted = true;
        PromotedCategory = Process;
        RunObject = Codeunit B2C;
        }
    }
   }
}