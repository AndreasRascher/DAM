table 110002 DMTCopyTable
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
        field(11; SourceCompanyName; Text[30])
        {
            Caption = 'Copy from Company', Comment = 'Kopieren aus Mandant';
            TableRelation = Company.Name where(Name = field(ExcludeSourceCompanyFilter));
        }
        field(13; Description; Text[250]) { CaptionML = DEU = 'Beschreibung', ENU = 'Description'; }
        field(14; ExcludeSourceCompanyFilter; Text[250]) { FieldClass = FlowFilter; Caption = 'ExcludeSourceCompanyFilter', Locked = true; }
        field(52; "Import Only New Records"; Boolean) { Caption = 'Import Only New Records', Comment = 'Nur neue Datensätze importieren'; }
        field(50; TableView; Blob) { }
        field(51; FilterText; Text[250]) { Caption = 'Filter', Comment = 'Filter'; Editable = false; }
        field(100; "Processing Time"; Duration) { CaptionML = DEU = 'Bearbeitungzeit', ENU = 'Processing Time'; Editable = false; }
        field(101; "No. of Records(Target)"; Integer) { CaptionML = DEU = 'Anz. Datensätze', ENU = 'No. of Records'; Editable = false; }
        field(102; "No. of Records inserted"; Integer) { CaptionML = DEU = 'Anz. importiert', ENU = 'No. of Records imported'; Editable = false; }
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
        Rec.TableView.CreateOutStream(OStr);
        OStr.WriteText(TableViewAsText);
        Rec.Modify();
    end;

    procedure LoadTableView() TableViewAsText: Text
    var
        IStr: InStream;
    begin
        Rec.CalcFields(TableView);
        if not Rec.TableView.HasValue then exit('');
        Rec.TableView.CreateInStream(IStr);
        IStr.ReadText(TableViewAsText);
    end;

    procedure EditSavedFilters() Continue: Boolean
    var
        SourceRef: RecordRef;
    begin
        Continue := true; // Canceling the dialog should stop th process
        SourceRef.Open(Rec."Table No.", false, Rec.SourceCompanyName);
        if Rec.LoadTableView() <> '' then
            SourceRef.SetView(Rec.LoadTableView());
        if not ShowRequestPageFilterDialog(SourceRef) then
            exit(false);
        if SourceRef.HasFilter then begin
            Rec.SaveTableView(SourceRef.GetView());
            Rec.FilterText := SourceRef.GetFilters();
        end else begin
            Rec.SaveTableView('');
            Rec.FilterText := '';
        end;
        Rec.Modify();
    end;


    procedure ShowRequestPageFilterDialog(var BufferRef: RecordRef) Continue: Boolean;
    var
        FPBuilder: FilterPageBuilder;
        Index: Integer;
        PrimaryKeyRef: KeyRef;
    begin
        FPBuilder.AddTable(BufferRef.Caption, BufferRef.Number);// ADD DATAITEM
        if BufferRef.HasFilter then // APPLY CURRENT FILTER SETTING 
            FPBuilder.SetView(BufferRef.Caption, BufferRef.GetView());

        // [OPTIONAL] ADD KEY FIELDS TO REQUEST PAGE AS REQUEST FILTER FIELDS for GIVEN RECORD
        PrimaryKeyRef := BufferRef.KeyIndex(1);
        for Index := 1 to PrimaryKeyRef.FieldCount do
            FPBuilder.AddFieldNo(BufferRef.Caption, PrimaryKeyRef.FieldIndex(Index).Number);
        // START FILTER PAGE DIALOG, CANCEL LEAVES OLD FILTER UNTOUCHED
        Continue := FPBuilder.RunModal();
        BufferRef.SetView(FPBuilder.GetView(BufferRef.Caption));
    end;

    procedure CopyToTemp(var TempCopyTable: Record DMTCopyTable temporary)
    var
        CopyTable: Record DMTCopyTable;
        TempCopyTable2: Record DMTCopyTable temporary;
    begin
        CopyTable.Copy(Rec);
        if CopyTable.FindSet(false, false) then
            repeat
                TempCopyTable2 := CopyTable;
                TempCopyTable2.Insert(false);
            until CopyTable.Next() = 0;
        TempCopyTable.Copy(TempCopyTable2, true);
    end;
}