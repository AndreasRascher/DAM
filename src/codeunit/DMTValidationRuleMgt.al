codeunit 110011 "DMTValidationRuleMgt"
{
    procedure SetKnownValidationRules(var DMTField: Record DMTField)
    var
        TargetField: Record Field;
        KnownFixedValue: Text;
        KnownUseTryFunction, KnownUseValidate : Boolean;
    begin
        TargetField.get(DMTField."Target Table ID", DMTField."Target Field No.");
        if FindKnownUseTryFunction(TargetField, KnownUseTryFunction) then
            DMTField."Use Try Function" := KnownUseTryFunction;
        if FindKnownUseValidateValue(TargetField, KnownUseValidate) then
            DMTField."Validate Value" := KnownUseValidate;
        if FindKnownFixedValue(TargetField, KnownFixedValue) then
            DMTField.Validate("Fixed Value", KnownFixedValue);
    end;

    local procedure FindKnownUseTryFunction(TargetField: Record Field; var KnownUseTryFunction: Boolean) Found: Boolean
    begin
        KnownUseTryFunction := true;
        Found := true;
        case true of
            IsMatch(TargetField, 'VAT Registration No.'),
            IsMatch(TargetField, 'E-Mail'),
            IsMatch(TargetField, 'Global Dimension 1 Code'),
            IsMatch(TargetField, 'Global Dimension 2 Code'),
            IsMatch(TargetField, Database::Item, 'Costing Method'),
            IsMatch(TargetField, Database::Item, 'Tariff No.'),
            IsMatch(TargetField, Database::Item, 'Base Unit of Measure'),
            IsMatch(TargetField, Database::Item, 'Indirect Cost %'),
            IsMatch(TargetField, Database::Item, 'Standard Cost'),
            IsMatch(TargetField, Database::"Fixed Asset", 'Budgeted Asset'),
            IsMatch(TargetField, Database::"Company Information", 'IC Partner Code'),
            IsMatch(TargetField, Database::"Company Information", 'IC Inbox Type'),
            IsMatch(TargetField, Database::"Company Information", 'IC Inbox Details'),
            IsMatch(TargetField, Database::"General Ledger Setup"),
            IsMatch(TargetField, Database::"Depreciation Book", 'Fiscal Year 365 Days'),
            IsMatch(TargetField, Database::"Sales Header", 'Sell-to Customer No.'),
            IsMatch(TargetField, Database::"Sales Header", 'Bill-to Customer No.'):
                KnownUseTryFunction := false;
            else
                Found := false;
        end;
    end;

    local procedure FindKnownUseValidateValue(TargetField: Record Field; var KnownUseValidate: Boolean) Found: Boolean
    begin
        KnownUseValidate := true;
        Found := true;
        case true of
            IsMatch(TargetField, 'VAT Registration No.'),
            IsMatch(TargetField, Database::"Location", 'ESCM In Behalf of Customer No.'),
            IsMatch(TargetField, Database::"Stockkeeping Unit", 'Phys Invt Counting Period Code'),
            IsMatch(TargetField, Database::"Stockkeeping Unit", 'Standard Cost'),
            IsMatch(TargetField, Database::"G/L Account", 'Totaling'),
            IsMatch(TargetField, Database::Customer, 'Primary Contact No.'),
            IsMatch(TargetField, Database::Customer, 'Contact'),
            IsMatch(TargetField, Database::Customer, 'Block Payment Tolerance'),
            IsMatch(TargetField, Database::Customer, 'Bill-to Customer No.'),
            IsMatch(TargetField, Database::Vendor, 'Primary Contact No.'),
            IsMatch(TargetField, Database::Vendor, 'Contact'),
            IsMatch(TargetField, Database::Vendor, 'Prices Including VAT'),
            IsMatch(TargetField, Database::Contact, 'Company No.'):
                KnownUseValidate := false;
            else
                Found := false;
        end;
    end;

    procedure IsMatch(Field: Record Field; Field1: Text) IsMatch: Boolean
    begin
        IsMatch := (Field.FieldName = Field1);
    end;

    procedure IsMatch(Field: Record Field; TableNo: Integer) IsMatch: Boolean
    begin
        IsMatch := (Field.TableNo = TableNo);
    end;

    procedure IsMatch(Field: Record Field; TableNo: Integer; FieldName: Text) IsMatch: Boolean
    begin
        IsMatch := (Field.TableNo = TableNo) and (Field.FieldName = FieldName);
    end;

    local procedure FindKnownFixedValue(TargetField: Record Field; KnownFixedValue: Text) Found: Boolean
    begin
        KnownFixedValue := '';
        Found := true;
        case true of
            else
                Found := false;
        end;
    end;

    /*
    case true of
 



 
                    (TargetField.TableNo = Database::"Production BOM Header") and
                    (TargetField.FieldName IN ['Status']):
                        begin
                            ProdBOMHeader.Status := ProdBOMHeader.Status::"Under Development";
                            DMTFields2.Validate("Fixed Value", Format(ProdBOMHeader.Status));
                        end;
                    (TargetField.TableNo = Database::"Production BOM Version") and
                    (TargetField.FieldName IN ['Status']):
                        begin
                            ProdBOMVersion.Status := ProdBOMVersion.Status::"Under Development";
                            DMTFields2.Validate("Fixed Value", Format(ProdBOMVersion.Status));
                        end;
                    (TargetField.TableNo = Database::"Routing Header") and
                    (TargetField.FieldName IN ['Status']):
                        begin
                            RoutingHeader.Status := RoutingHeader.Status::"Under Development";
                            DMTFields2.Validate("Fixed Value", Format(RoutingHeader.Status));
                        end;

                    (TargetField.TableNo = Database::"Customer Posting Group") and
                    (TargetField.FieldName.Contains('Account') or TargetField.FieldName.Contains('Acc.')):
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                    (TargetField.TableNo = Database::"Vendor Posting Group") and
                    (TargetField.FieldName.Contains('Account') or TargetField.FieldName.Contains('Acc.')):
                        begin
                            DMTFields2."Use Try Function" := false;
                        end;
                end;
    */


}