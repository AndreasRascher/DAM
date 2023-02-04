// page 110006 DMTReplacementRules
// {
//     Caption = 'DMT Replacement Rules', Comment = 'DMT Ersetzungsregeln';
//     PageType = List;
//     ApplicationArea = All;
//     UsageCategory = Administration;
//     SourceTable = DMTReplacementsHeaderOLD;
//     DelayedInsert = true;
//     CardPageId = DMTReplacementsCard;

//     layout
//     {
//         area(Content)
//         {
//             repeater(Repeater)
//             {
//                 field("To Table No."; Rec.Code) { ApplicationArea = All; }
//                 field("To Field No."; Rec.Description) { ApplicationArea = All; }
//                 field("No. of Lines"; Rec."No. of Lines") { ApplicationArea = All; }
//             }
//         }
//     }
// }