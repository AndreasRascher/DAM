// codeunit 110011 "DMTValidationRuleMgt"
// {
//     local procedure AddRule_ValidateValueIsFALSE(TableID: Integer; FieldName: Text)
//     var
//         CurrFieldNameList: List of [Text];
//     begin
//         if TableField_ValidateValueIsFALSE.ContainsKey(TableID) then begin
//             CurrFieldNameList := TableField_ValidateValueIsFALSE.Get(TableID);
//             if not CurrFieldNameList.Contains(FieldName) then begin
//                 CurrFieldNameList.Add(FieldName);
//                 TableField_ValidateValueIsFALSE.Set(TableID, CurrFieldNameList);
//             end;
//         end else begin
//             CurrFieldNameList.Add(FieldName);
//             TableField_ValidateValueIsFALSE.Add(TableID, CurrFieldNameList);
//         end;

//     end;

//     local procedure AddRule_UseTryFunctionFALSE(TableID: Integer; FieldName: Text)
//     begin

//     end;

//     local procedure AddRule_DefaultValue(TableID: Integer; FieldName: Text; DefaultValue: Text)
//     var
//         DefaultFieldValue: Dictionary of [Text, Text];
//     begin
//         DefaultFieldValue.Add(FieldName, DefaultValue);
//         Field_DefaultValue.Add(TableID, DefaultFieldValue)
//     end;

//     /// <summary>
//     /// Set Use Try Functions for all Tables with the given FieldName
//     /// </summary>
//     /// <param name="TableID"></param>
//     /// <param name="FieldName"></param>
//     /// <param name="DefaultValue"></param>
//     local procedure AddRule_FieldName_UseTryFunctionFALSE(FieldName: Text)
//     begin
//         FieldName_UseTryFunctionFALSE.Add(FieldName);
//     end;

//     local procedure AddRule_FieldName_ValidateValueIsFALSE(FieldName: Text)
//     begin
//         FieldName_ValidateValueIsFALSE.Add(FieldName);
//     end;


//     procedure LoadRules()
//     var
//         ProdBOMHeader: Record "Production BOM Header";
//         ProdBOMVersion: Record "Production BOM Version";
//         RoutingHEader: Record "Routing Header";
//     begin
//         AddRule_FieldName_UseTryFunctionFALSE(Database::"Customer Posting Group",);
//         //                 (TargetField.TableNo = Database::"Customer Posting Group") and
//         //                 (TargetField.FieldName.Contains('Account') or TargetField.FieldName.Contains('Acc.')):
//         //                     begin
//         //                         DMTFields2."Use Try Function" := false;
//         //                     end;
//         //                 (TargetField.TableNo = Database::"Vendor Posting Group") and
//         //                 (TargetField.FieldName.Contains('Account') or TargetField.FieldName.Contains('Acc.')):
//         //                     begin
//         //                         DMTFields2."Use Try Function" := false;
//         //                     end;
//         //#15      G/L Account
//         AddRule_ValidateValueIsFALSE(Database::"G/L Account", 'Totaling');

//         //#5050    Contact
//         AddRule_ValidateValueIsFALSE(Database::Contact, 'Company No.');

//         //#18      Customer
//         AddRule_ValidateValueIsFALSE(Database::Customer, 'Primary Contact No.');
//         AddRule_ValidateValueIsFALSE(Database::Customer, 'Contact');
//         AddRule_ValidateValueIsFALSE(Database::Customer, 'Block Payment Tolerance');
//         AddRule_ValidateValueIsFALSE(Database::Customer, 'Bill-to Customer No.');

//         // Vendor
//         AddRule_ValidateValueIsFALSE(Database::Vendor, 'Primary Contact No.');
//         AddRule_ValidateValueIsFALSE(Database::Vendor, 'Contact');
//         AddRule_ValidateValueIsFALSE(Database::Vendor, 'Prices Including VAT');

//         // Item
//         AddRule_UseTryFunctionFALSE(Database::Item, 'Costing Method');
//         AddRule_UseTryFunctionFALSE(Database::Item, 'Tariff No.');
//         AddRule_UseTryFunctionFALSE(Database::Item, 'Base Unit of Measure');
//         AddRule_UseTryFunctionFALSE(Database::Item, 'Indirect Cost %');
//         AddRule_UseTryFunctionFALSE(Database::Item, 'Standard Cost');

//         // Prod. BOM Header
//         AddRule_DefaultValue(Database::"Production BOM Header", 'Status', Format(Enum::"BOM Status"::"Under Development"));

//         // Prod. BOM Version
//         AddRule_DefaultValue(Database::"Production BOM Header", 'Status', Format(Enum::"BOM Status"::"Under Development"));

//         // Routing Header
//         AddRule_DefaultValue(Database::"Routing Header", 'Status', Format(Enum::"Routing Status"::"Under Development"));

//         // Global Rules
//         AddRule_FieldName_UseTryFunctionFALSE('Global Dimension 1 Code');
//         AddRule_FieldName_UseTryFunctionFALSE('Global Dimension 2 Code');
//         AddRule_FieldName_UseTryFunctionFALSE('VAT Registration No.');
//         AddRule_FieldName_ValidateValueIsFALSE('VAT Registration No.');
//         AddRule_FieldName_UseTryFunctionFALSE('E-Mail');

//     end;

//     var
//         TableField_ValidateValueIsFALSE: Dictionary of [Integer, List of [Text]];
//         FieldName_UseTryFunctionFALSE: List of [Text];
//         FieldName_ValidateValueIsFALSE: List of [Text];
//         Field_DefaultValue: Dictionary of [Integer, Dictionary of [Text, Text]];
//     // repeat
//     //             TargetField.Get(DMTFields."Target Table ID", DMTFields."Target Field No.");
//     // DMTFields2 := DMTFields;
//     // case true of






//     //                 (TargetField.TableNo = Database::"Fixed Asset") and (TargetField.FieldName in ['Budgeted Asset']):
//     //                     begin
//     //                         DMTFields2."Use Try Function" := false;
//     //                     end;
//     //                 (TargetField.TableNo = Database::"Company Information") and (TargetField.FieldName in ['IC Partner Code', 'IC Inbox Type', 'IC Inbox Details']):
//     //                     begin
//     //                         DMTFields2."Use Try Function" := false;
//     //                     end;
//     //                 (TargetField.TableNo = Database::"General Ledger Setup"):
//     //                     begin
//     //                         DMTFields2."Use Try Function" := false;
//     //                     end;
//     //                 (TargetField.TableNo = Database::"Location") and (TargetField.FieldName IN ['ESCM In Behalf of Customer No.']):
//     //                     begin
//     //                         DMTFields2."Validate Value" := false;
//     //                     end;
//     //             end;

//     //             if format(DMTFields2) <> Format(DMTFields) then
//     //                 DMTFields2.Modify()
//     //         until DMTFields.Next() = 0;
// }