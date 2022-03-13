table 91006 "DMTTask"
{
    DataClassification = SystemMetadata;
    CaptionML = DEU = 'DMT Aufgabe', ENU = 'DMT Tast';
    LookupPageId = DMTTaskList;
    DrillDownPageId = DMTTaskList;

    fields
    {
        field(1; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(10; Type; Option)
        {
            OptionMembers = " ",ImportToBuffer,ImportToTarget,RunCodeunit;
            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    Clear(Rec."Context Description");
                    Clear(Rec.ID);
                    Clear(Rec.TableView);
                end;
            end;
        }
        field(11; ID; integer)
        {
            TableRelation = if (Type = const(ImportToBuffer)) DMTTable."To Table ID" else
            if (Type = const(ImportToTarget)) DMTTable."To Table ID" else
            if (Type = const(RunCodeunit)) AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit), "Object ID" = filter(50000 ..));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                DMTTable: Record DMTTable;
                AllObjWithCaption: Record AllObjWithCaption;
            begin
                case Type of
                    Type::ImportToBuffer, Type::ImportToTarget:
                        begin
                            DMTTable.Get(Rec.ID);
                            DMTTable.testfield("Buffer Table ID");
                            Rec."Context Description" := DMTTable."Dest.Table Caption";
                        end;
                    Type::RunCodeunit:
                        begin
                            AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Codeunit, Rec.ID);
                            Rec."Context Description" := AllObjWithCaption."Object Caption";
                        end;
                end;
            end;
        }
        field(12; "Context Description"; text[250])
        {
            CaptionML = DEU = 'Kontext Beschreibung', ENU = 'Context Description';
        }
        field(50; TableView; Blob) { }
        field(100; "Processing Time"; Duration)
        {
            CaptionML = DEU = 'Bearbeitungzeit', ENU = 'Processing Time';
        }
        field(101; "No. of Records"; Integer)
        {
            CaptionML = DEU = 'Anz. Datensätze', ENU = 'No. of Records';
        }
        field(102; "No. of Records failed"; Integer)
        {
            CaptionML = DEU = 'Anz. fehlgeschlagen', ENU = 'No. of Records failed';
        }
        field(103; "No. of Records imported"; Integer)
        {
            CaptionML = DEU = 'Anz. importiert', ENU = 'No. of Records imported';
        }
    }

    keys
    {
        key(PK; "Line No.") { Clustered = true; }
    }

    fieldgroups
    {
        fieldgroup(Brick; "No. of Records", "No. of Records failed", "No. of Records imported")
        {
            Caption = 'MyBrick';
        }
    }

    procedure SaveTableView(TableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec.TableView);
        Rec.Modify();
        rec.TableView.CreateOutStream(Ostr);
        OStr.WriteText(TableView);
        Rec.Modify();
    end;

    procedure GetStoredTableView() TableView: Text
    var
        IStr: InStream;
    begin
        rec.calcfields(TableView);
        if not rec.TableView.HasValue then exit('');
        rec.TableView.CreateInStream(IStr);
        IStr.ReadText(TableView);
    end;

    procedure GetStoredTableViewAsFilter() FilterExpr: Text
    var
        DMTTable: Record DMTTable;
        TableMetadata: Record "Table Metadata";
        RecRef: RecordRef;
        StoredTableView: text;
    begin
        StoredTableView := GetStoredTableView();
        if StoredTableView = '' then exit('');
        if not Rec.FindRelated(DMTTable) then exit;
        if DMTTable."Buffer Table ID" = 0 then
            exit;
        if not TableMetadata.Get(DMTTable."Buffer Table ID") then
            exit;
        RecRef.Open(DMTTable."Buffer Table ID");
        RecRef.SetView(StoredTableView);
        FilterExpr := RecRef.GetFilters();
    end;

    internal procedure FindRelated(var DMTTable: Record DMTTable) OK: Boolean
    begin
        Clear(DMTTable);
        if not (Rec.Type IN [Rec.Type::ImportToBuffer, Rec.Type::ImportToTarget]) then
            exit(false);
        if Rec.ID = 0 then
            exit(false);
        OK := DMTTable.Get(Rec.ID);
    end;

    internal procedure FindRelated(var AllObjWithCaption_Codeunit: Record AllObjWithCaption) OK: Boolean;
    begin
        if (Rec.ID = 0) or (Rec.Type <> Rec.Type::RunCodeunit) then exit(false);
        OK := AllObjWithCaption_Codeunit.Get(AllObjWithCaption_Codeunit."Object Type"::Codeunit, Rec.ID);
    end;

}