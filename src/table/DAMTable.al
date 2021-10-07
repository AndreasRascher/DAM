table 91000 "DAMTable"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Code"; Code[50])
        {
            DataClassification = SystemMetadata;
            CaptionML = DEU = 'Code', ENU = 'Code';
        }
        field(10; "Description"; Text[100])
        {
            DataClassification = SystemMetadata;
            CaptionML = DEU = 'Beschreibung', ENU = 'Description';
        }
        field(20; "From Table ID"; Integer)
        {
            CaptionML = DEU = 'Herkunft Tabellen ID', ENU = 'Source Table ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table), "Object ID" = filter('50000..'));
        }
        field(21; "Qty.Lines In Src. Table"; Integer)
        {
            CaptionML = DEU = 'Anz. Zeilen in Herkunftstabelle', ENU = 'Qty.Lines in source table';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("From Table ID")));
            Editable = false;
            trigger OnLookup()
            begin
                ShowTableContent("From Table ID");
            end;
        }
        field(30; "To Table ID"; Integer)
        {
            CaptionML = DEU = 'Ziel Tabellen ID', ENU = 'Target Table ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(31; "Qty.Lines In Trgt. Table"; Integer)
        {
            CaptionML = DEU = 'Anz. Zeilen in Zieltabelle', ENU = 'Qty.Lines in source table';
            FieldClass = FlowField;
            CalcFormula = lookup("Table Information"."No. of Records" where("Table No." = field("To Table ID")));
            Editable = false;
            trigger OnLookup()
            begin
                ShowTableContent("From Table ID");
            end;
        }
        field(50; ExportFilePath; Text[250])
        {
            CaptionML = DEU = 'Dateipfad Exportdatei', ENU = 'Export File Path';
            trigger OnValidate()
            var
                FileMgt: Codeunit "File Management";
                FileNotAccessibleFromServiceLabelMsg: TextConst DEU = 'Der Pfad "%1" konnte vom Service Tier nicht erreicht werden', ENU = 'The path "%1" is not accessibly for the service tier';
            begin
                if rec.ExportFilePath <> '' then begin
                    rec.ExportFilePath := CopyStr(rec.ExportFilePath.TrimEnd('"').TrimStart('"'), 1, MaxStrLen(rec.ExportFilePath));
                    if not FileMgt.ServerFileExists(rec.ExportFilePath) then
                        Message(FileNotAccessibleFromServiceLabelMsg, ExportFilePath);
                end;
            end;
        }
        field(51; "Import XMLPort ID"; Integer)
        {
            CaptionML = DEU = 'XMLPort für Import', ENU = 'Import XMLPortID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLPort), "Object ID" = filter('50000..'));
        }
        field(60; "Use OnInsert Trigger"; boolean)
        {
            CaptionML = DEU = 'OnInsert Trigger verwenden', ENU = 'Use OnInsert Trigger';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DAMFields: Record DAMFields;
    begin
        if DAMFields.FilterBy(Rec) then
            DAMFields.DeleteAll(true);
    end;

    internal procedure ImportToBufferTable()
    var
        File: File;
        InStr: InStream;
    begin
        rec.TestField("Import XMLPort ID");
        rec.Testfield(ExportFilePath);
        file.Open(ExportFilePath, TextEncoding::MSDos);
        file.CreateInStream(InStr);
        Xmlport.Import(Rec."Import XMLPort ID", InStr);
    end;

    internal procedure ShowTableContent(TableID: Integer)
    begin
        if TableID = 0 then exit;
        Hyperlink(GetUrl(CurrentClientType, CompanyName, ObjectType::Table, TableID));
    end;

}