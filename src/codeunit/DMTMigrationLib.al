codeunit 73008 DMTMigrationLib
{
    procedure FindFieldNameInOldVersion(FieldName: Text; TargetTableNo: Integer; var OldFieldName: Text) Found: Boolean
    begin
        //* Hier Felder eintragen die in neueren Versionen umbenannt wurden, deren Werte aber 1:1 kopiert werden können
        Clear(OldFieldName);
        case true of
            (TargetTableNo = Database::Customer) and (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = Database::Vendor) and (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = Database::Contact) and (FieldName = 'Country/Region Code'):
                OldFieldName := 'Country Code';
            (TargetTableNo = Database::Item) and (FieldName = 'Country/Region of Origin Code'):
                OldFieldName := 'Country of Origin Code';
            (TargetTableNo = Database::Item) and (FieldName = 'Time Bucket'):
                OldFieldName := 'Reorder Cycle';
            // Item Cross Reference -> Item Reference
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference Type'):
                OldFieldName := 'Cross-Reference Type';
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference Type No.'):
                OldFieldName := 'Cross-Reference Type No.';
            (TargetTableNo = Database::"Item Reference") and (FieldName = 'Reference No.'):
                OldFieldName := 'Cross-Reference No.';
        end; // end_CASE
        Found := OldFieldName <> '';
    end;

    procedure ApplyKnownValidationRules(var FieldMapping: Record DMTFieldMapping)
    var
        TargetField: Record Field;
        ValidationType: Enum DMTFieldValidationType;
        KnownFixedValue: Text;
    begin
        TargetField.Get(FieldMapping."Target Table ID", FieldMapping."Target Field No.");
        if FindKnownUseValidateValue(TargetField, ValidationType) then
            FieldMapping."Validation Type" := ValidationType;
        if FindKnownFixedValue(TargetField, KnownFixedValue) then
            FieldMapping.Validate("Fixed Value", KnownFixedValue);
        if FindKnownFieldsToIgnore(TargetField) then
            FieldMapping."Processing Action" := FieldMapping."Processing Action"::Ignore;
    end;

    /// <summary>
    /// List of known fields with blocking logic(ValidateCode / Self references in Table Telations). Validation type is set to AssignWithoutValidate.
    /// </summary>
    /// <param name="TargetField"></param>
    /// <param name="KnownValidationType"></param>
    /// <returns></returns>
    local procedure FindKnownUseValidateValue(TargetField: Record Field; var KnownValidationType: Enum DMTFieldValidationType) Found: Boolean
    var
    // RoutingHeader: Record "Routing Header";
    // Contact: Record Contact;
    begin
        KnownValidationType := KnownValidationType::AlwaysValidate;
        Found := true;
        case true of
            IsMatch(TargetField, 'VAT Registration No.'),
            IsMatch(TargetField, Database::Location, 'ESCM In Behalf of Customer No.'),
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
            IsMatch(TargetField, Database::Vendor, 'Pay-to Vendor No.'),
            IsMatch(TargetField, Database::Contact, 'Company No.'),
            IsMatch(TargetField, Database::Contact, 'First Name'),  // Avoid ProcessNameChange to clear Names
            IsMatch(TargetField, Database::Contact, 'Middle Name'),
            IsMatch(TargetField, Database::Contact, 'Surname'),
            IsMatch(TargetField, Database::Item, 'Sales Unit of Measure'),
            IsMatch(TargetField, Database::Item, 'Purch. Unit of Measure'),
            IsMatch(TargetField, Database::Item, 'Unit Cost'),
            IsMatch(TargetField, Database::Item, 'Rounding Precision'),
            IsMatch(TargetField, Database::Item, 'Standard Cost'),
            IsMatch(TargetField, Database::Item, 'Indirect Cost %'),
            IsMatch(TargetField, Database::"Item Unit of Measure", 'Qty. per Unit of Measure'),
            IsMatch(TargetField, Database::"Routing Header", 'Status'),
            IsMatch(TargetField, Database::"Extended Text Header", 'Language Code'), /* Possible in old version to have Language Code + All Language */
            IsMatch(TargetField, Database::"Extended Text Header", 'All Language Codes'): /* Possible in old version to have Language Code + All Language */
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
            // Picture BLOBs
            IsMatch(TargetField, Database::Item, 'Picture'),
            IsMatch(TargetField, Database::"Company Information", 'Picture'),
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

    procedure UpdateGlobalDimNoInDimensionValues()
    var
        DimValue: Record "Dimension Value";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();

        if GLSetup."Global Dimension 1 Code" <> '' then begin
            DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 1 Code");
            DimValue.ModifyAll("Global Dimension No.", 1);
        end;

        if GLSetup."Global Dimension 2 Code" <> '' then begin
            DimValue.SetRange("Dimension Code", GLSetup."Global Dimension 2 Code");
            DimValue.ModifyAll("Global Dimension No.", 2);
        end;
    end;

    internal procedure RunPostProcessingFor(var DataFile: Record DMTDataFile)
    begin
        if DataFile."Target Table ID" = Database::"Dimension Value" then
            UpdateGlobalDimNoInDimensionValues();
    end;

    internal procedure ApplyKnownProcessingRulesToNewDataFileRec(var DataFile: Record DMTDataFile)
    begin
        case DataFile."Target Table ID" of
            Database::"Item Vendor",
          Database::Customer,
          Database::Vendor,
          Database::"Extended Text Header":   /* Avoid renumbering key field "Text No." */
                DataFile."Use OnInsert Trigger" := false;
        end;
    end;
}