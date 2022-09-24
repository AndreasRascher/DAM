codeunit 110011 "DMTMigrationLib"
{
    procedure FindFieldNameInOldVersion(FieldName: Text; TargetTableNo: Integer; var OldFieldName: Text) Found: Boolean
    begin
        //* Hier Felder eintragen die in neueren Versionen umbenannt wurden, deren Werte aber 1:1 kopiert werden können
        CLEAR(OldFieldName);
        CASE TRUE OF
            (TargetTableNo = DATABASE::Customer) AND (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Vendor) AND (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Contact) AND (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = DATABASE::Item) AND (FieldName = 'Country/Region of Origin Code'):
                OldFieldName := 'Country of Origin Code';
            (TargetTableNo = DATABASE::Item) AND (FieldName = 'Time Bucket'):
                OldFieldName := 'Reorder Cycle';
            // Item Cross Reference -> Item Reference
            (TargetTableNo = DATABASe::"Item Reference") AND (FieldName = 'Reference Type'):
                OldFieldName := 'Cross-Reference Type';
            (TargetTableNo = DATABASe::"Item Reference") AND (FieldName = 'Reference Type No.'):
                OldFieldName := 'Cross-Reference Type No.';
            (TargetTableNo = DATABASe::"Item Reference") AND (FieldName = 'Reference No.'):
                OldFieldName := 'Cross-Reference No.';
        end; // end_CASE
        Found := OldFieldName <> '';
    end;

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

    procedure SetKnownValidationRules(var FieldMapping: Record DMTFieldMapping)
    var
        TargetField: Record Field;
        KnownFixedValue: Text;
        KnownUseTryFunction, KnownUseValidate : Boolean;
    begin
        TargetField.get(FieldMapping."Target Table ID", FieldMapping."Target Field No.");
        if FindKnownUseTryFunction(TargetField, KnownUseTryFunction) then
            FieldMapping."Use Try Function" := KnownUseTryFunction;
        if FindKnownUseValidateValue(TargetField, KnownUseValidate) then
            if not KnownUseValidate then
                FieldMapping."Validation Type" := Enum::DMTFieldValidationType::AssignWithoutValidate;
        if FindKnownFixedValue(TargetField, KnownFixedValue) then
            FieldMapping.Validate("Fixed Value", KnownFixedValue);
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
            HasTableRelation(TargetField, Database::"Customer Posting Group", Database::"G/L Account"),
            HasTableRelation(TargetField, Database::"Vendor Posting Group", Database::"G/L Account"),
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
            IsMatch(TargetField, Database::"Sales Header", 'Bill-to Customer No.'),
            IsMatch(TargetField, Database::Customer, 'Block Payment Tolerance'):
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

    procedure HasTableRelation(Field: Record Field; TableNo: Integer; RelatedToTableNo: Integer) HasRelation: Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(Field.TableNo, true);
        HasRelation := RecRef.Field(Field."No.").Relation = RelatedToTableNo;
    end;

    local procedure FindKnownFixedValue(TargetField: Record Field; KnownFixedValue: Text) Found: Boolean
    begin
        KnownFixedValue := '';
        Found := true;
        case true of
            IsMatch(TargetField, Database::"Production BOM Header", 'Status'),
            IsMatch(TargetField, Database::"Production BOM Version", 'Status'):
                KnownFixedValue := Format(Enum::"BOM Status"::"Under Development");
            IsMatch(TargetField, Database::"Routing Header", 'Status'):
                KnownFixedValue := Format(Enum::"Routing Status"::"Under Development");
            else
                Found := false;
        end;
    end;
}