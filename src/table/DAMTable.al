table 91001 "DAMTable"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "From Table ID"; Integer)
        {
            CaptionML = DEU = 'Von Tab.-ID', ENU = 'From Tab.-ID';
            DataClassification = SystemMetadata;
        }
        field(2; "To Table ID"; Integer)
        {
            CaptionML = DEU = 'Nach Tabellen ID', ENU = 'To Table ID';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table), "Object ID" = filter('50000..'));
        }
        field(3; "From Table Caption"; Text[250])
        {
            CaptionML = DEU = 'Von', ENU = 'From';
            trigger OnLookup()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.LookUpFromTable(Rec);
            end;

            trigger OnValidate()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.ValidateFromTableCaption(Rec, xRec);
            end;
        }
        field(4; "To Table Caption"; Text[250])
        {
            CaptionML = DEU = 'Nach', ENU = 'To';
            trigger OnLookup()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.LookUpToTable(Rec);
            end;

            trigger OnValidate()
            var
                ObjectMgt: Codeunit ObjMgt;
            begin
                ObjectMgt.ValidateToTableCaption(Rec, xRec);
            end;
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
            CaptionML = DEU = 'XMLPort ID für Import', ENU = 'Import XMLPortID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(XMLPort), "Object ID" = filter('50000..'));
        }
        field(52; "Buffer Table ID"; Integer)
        {
            CaptionML = DEU = 'Puffertabelle ID', ENU = 'Buffertable ID';
            MinValue = 50000;
            MaxValue = 99999;
        }
        field(60; "Use OnInsert Trigger"; boolean)
        {
            CaptionML = DEU = 'OnInsert Trigger verwenden', ENU = 'Use OnInsert Trigger';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "From Table ID", "To Table ID")
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