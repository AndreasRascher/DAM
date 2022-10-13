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

    procedure ApplyKnownValidationRules(var FieldMapping: Record DMTFieldMapping)
    var
        TargetField: Record Field;
        KnownFixedValue: Text;
        ValidationType: Enum DMTFieldValidationType;
    begin
        TargetField.get(FieldMapping."Target Table ID", FieldMapping."Target Field No.");
        if FindKnownUseValidateValue(TargetField, ValidationType) then
            FieldMapping."Validation Type" := ValidationType;
        if FindKnownFixedValue(TargetField, KnownFixedValue) then
            FieldMapping.Validate("Fixed Value", KnownFixedValue);
        if FindKnownFieldsToIgnore(TargetField) then
            FieldMapping."Processing Action" := FieldMapping."Processing Action"::Ignore;
    end;

    local procedure FindKnownUseValidateValue(TargetField: Record Field; var KnownValidationType: Enum DMTFieldValidationType) Found: Boolean
    begin
        KnownValidationType := KnownValidationType::AlwaysValidate;
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
                KnownValidationType := KnownValidationType::AssignWithoutValidate;
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

    local procedure FindKnownFieldsToIgnore(TargetField: Record Field) Found: Boolean
    begin
        case true of
            // Sales Header
            IsMatch(TargetField, Database::"Sales Header", 'Invoice'),
            IsMatch(TargetField, Database::"Sales Header", 'Ship'),
            IsMatch(TargetField, Database::"Sales Header", 'Receive'),
            // Testsfields on Recreate SalesLine
            IsMatch(TargetField, Database::"Sales Line", 'Job No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Job Contract Entry No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Quantity Invoiced'),
            IsMatch(TargetField, Database::"Sales Line", 'Return Qty. Received'),
            IsMatch(TargetField, Database::"Sales Line", 'Shipment No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Return Receipt No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Blanket Order No.'),
            IsMatch(TargetField, Database::"Sales Line", 'Prepmt. Amt. Inv.'),
            // Testfields on Recreate PurchLine
            IsMatch(TargetField, Database::"Purchase Line", 'Quantity Received'),
            IsMatch(TargetField, Database::"Purchase Line", 'Quantity Invoiced'),
            IsMatch(TargetField, Database::"Purchase Line", 'Return Qty. Shipped'),
            IsMatch(TargetField, Database::"Purchase Line", 'Receipt No.'),
            IsMatch(TargetField, Database::"Purchase Line", 'Return Shipment No.'),
            IsMatch(TargetField, Database::"Purchase Line", 'Blanket Order No.'):
                Found := true;
            else
                Found := false;
        end;
    end;
}