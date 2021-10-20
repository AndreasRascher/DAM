table 91006 DAMTask
{
    DataClassification = SystemMetadata;
    CaptionML = DEU = 'DAM Aufgabe', ENU = 'DAM Tast';

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
            TableRelation = if (Type = const(ImportToBuffer)) DAMTable."To Table ID" else
            if (Type = const(ImportToTarget)) DAMTable."To Table ID" else
            if (Type = const(RunCodeunit)) AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit), "Object ID" = filter(50000 ..));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                DAMTable: Record DAMTable;
                AllObjWithCaption: Record AllObjWithCaption;
            begin
                case Type of
                    Type::ImportToBuffer, Type::ImportToTarget:
                        begin
                            DAMTable.Get(Rec.ID);
                            DAMTable.testfield("Buffer Table ID");
                            Rec."Context Description" := DAMTable."To Table Caption";
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
        DAMTable: Record DAMTable;
        RecRef: RecordRef;
        StoredTableView: text;
    begin
        StoredTableView := GetStoredTableView();
        if StoredTableView = '' then exit('');
        if not Rec.FindRelated(DAMTable) then exit;
        if DAMTable."Buffer Table ID" = 0 then
            exit;
        RecRef.Open(DAMTable."Buffer Table ID");
        RecRef.SetView(StoredTableView);
        FilterExpr := RecRef.GetFilters();
    end;

    internal procedure FindRelated(var DAMTable: Record DAMTable) OK: Boolean
    begin
        Clear(DAMTable);
        if not (Rec.Type IN [Rec.Type::ImportToBuffer, Rec.Type::ImportToTarget]) then
            exit(false);
        if Rec.ID = 0 then
            exit(false);
        OK := DAMTable.Get(Rec.ID);
    end;

    internal procedure FindRelated(var AllObjWithCaption_Codeunit: Record AllObjWithCaption) OK: Boolean;
    begin
        if (Rec.ID = 0) or (Rec.Type <> Rec.Type::RunCodeunit) then exit(false);
        OK := AllObjWithCaption_Codeunit.Get(AllObjWithCaption_Codeunit."Object Type"::Codeunit, Rec.ID);
    end;

}