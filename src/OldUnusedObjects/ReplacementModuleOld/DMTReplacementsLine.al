// table 110007 DMTReplacementsLineOLD
// {
//     Caption = 'Replacements Line', Comment = 'Ersetzungen Zeile';
//     DataClassification = ToBeClassified;

//     fields
//     {
//         field(1; "Repl.Rule Code"; Code[50])
//         {
//             Caption = 'Code', comment = 'Code';
//             DataClassification = SystemMetadata;
//             TableRelation = DMTReplacementsHeaderOLD.Code;
//         }
//         field(2; "Line No."; Integer) { Caption = 'Line No.', Comment = 'Zeilennr.'; }
//         field(10; "Old Value"; Text[250]) { Caption = 'Old Value', Comment = 'Alter Wert'; }
//         field(11; "New Value"; Text[250]) { Caption = 'New Value', Comment = 'Neuer Wert'; }
//     }

//     keys
//     {
//         key(PK; "Repl.Rule Code", "Line No.") { Clustered = true; }
//     }

//     internal procedure filterFor(ReplacementRuleHeader: Record DMTReplacementsHeaderOLD) hasLines: Boolean
//     begin
//         Rec.SetRange("Repl.Rule Code", ReplacementRuleHeader.Code);
//         hasLines := not Rec.IsEmpty;
//     end;
// }