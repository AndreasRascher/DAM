// page 110007 DMTReplacementsAssignedSub
// {
//     Caption = 'Lines', Comment = 'Zeilen';
//     PageType = ListPart;
//     UsageCategory = None;
//     SourceTable = DMTFieldMapping;
//     DeleteAllowed = false;
//     InsertAllowed = false;

//     layout
//     {
//         area(Content)
//         {
//             repeater(Lines)
//             {
//                 field("To Field Caption"; Rec."Target Field Caption") { ApplicationArea = All; }
//                 field("To Table No."; Rec."Target Table ID") { ApplicationArea = All; }
//                 field("To Field No."; Rec."Target Field No.") { ApplicationArea = All; }
//                 field("Replacements Code"; Rec."Replacements Code") { ApplicationArea = All; }
//             }
//         }
//     }
// }