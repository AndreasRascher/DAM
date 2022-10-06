table 110000 "DMTCopyTable"
{
    DataClassification = SystemMetadata;
    Caption = 'DMT Copy Table', comment = 'DMT Tabellen kopieren';
    LookupPageId = DMTCopyTableList;
    DrillDownPageId = DMTCopyTableList;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.', Comment = 'Tabellen ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(2; "Line No."; Integer) { Caption = 'Line No.'; }
        field(10; "Table Caption"; Text[249])
        {
            Caption = 'Table Caption', Comment = 'Tabellen Bezeichnung';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
        }
        field(11; SourceCompany; Text[30])
        {
            Caption = 'Copy from Company', Comment = 'Kopieren aus Mandant';
            TableRelation = Company.Name where(Name = field(ExcludeSourceCompanyFilter));
        }
        field(13; "Context Description"; text[250]) { CaptionML = DEU = 'Kontext Beschreibung', ENU = 'Context Description'; }
        field(14; ExcludeSourceCompanyFilter; Text[250]) { FieldClass = FlowFilter; Caption = 'ExcludeSourceCompanyFilter', Locked = true; }
        field(50; TableView; Blob) { }
        field(100; "Processing Time"; Duration) { CaptionML = DEU = 'Bearbeitungzeit', ENU = 'Processing Time'; }
        field(101; "No. of Records"; Integer) { CaptionML = DEU = 'Anz. Datensätze', ENU = 'No. of Records'; }
        field(102; "No. of Records failed"; Integer) { CaptionML = DEU = 'Anz. fehlgeschlagen', ENU = 'No. of Records failed'; }
        field(103; "No. of Records imported"; Integer) { CaptionML = DEU = 'Anz. importiert', ENU = 'No. of Records imported'; }
    }

    keys
    {
        key(PK; "Table No.", "Line No.") { Clustered = true; }
    }

    fieldgroups { }

    procedure SaveTableView(TableViewAsText: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.TableView);
        Rec.Modify();
        rec.TableView.CreateOutStream(Ostr);
        OStr.WriteText(TableViewAsText);
        Rec.Modify();
    end;

    procedure LoadTableView() TableViewAsText: Text
    var
        IStr: InStream;
    begin
        rec.calcfields(TableView);
        if not rec.TableView.HasValue then exit('');
        rec.TableView.CreateInStream(IStr);
        IStr.ReadText(TableViewAsText);
    end;

    procedure ShowRequestPageFilterDialog(var BufferRef: RecordRef) Continue: Boolean;
    var
        FPBuilder: FilterPageBuilder;
        Index: Integer;
        PrimaryKeyRef: KeyRef;
    begin
        FPBuilder.AddTable(BufferRef.Caption, BufferRef.Number);// ADD DATAITEM
        IF BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SetView(BufferRef.CAPTION, BufferRef.GETVIEW());

        // [OPTIONAL] ADD KEY FIELDS TO REQUEST PAGE AS REQUEST FILTER FIELDS for GIVEN RECORD
        PrimaryKeyRef := BufferRef.KeyIndex(1);
        for Index := 1 to PrimaryKeyRef.FieldCount do
            FPBuilder.AddFieldNo(BufferRef.Caption, PrimaryKeyRef.FieldIndex(Index).Number);
        // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
        Continue := FPBuilder.RUNMODAL();
        BufferRef.SetView(FPBuilder.GetView(BufferRef.CAPTION));
    end;
}