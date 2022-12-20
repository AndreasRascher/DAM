table 110010 DMTProcessingPlan
{
    DataClassification = ToBeClassified;
    Caption = 'DMTProcessingPlan', Locked = true;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; Type; Enum DMTProcessingPlanType)
        {
            Caption = 'Type';

            trigger OnValidate()
            begin
                if xRec.Type = xRec.Type::" " then
                    if Rec.Type = Rec.Type::Group then begin
                        Clear(Description);
                        Clear(ID);
                    end;
            end;
        }
        field(11; ID; Integer)
        {
            Caption = 'DataFile ID';
            TableRelation =
            if (Type = const("Run Codeunit")) AllObjWithCaption."Object ID" where("Object Type" = const(Codeunit))
            else
            if (Type = const("Import To Buffer")) DMTDataFile.ID
            else
            if (Type = const("Import To Target")) DMTDataFile.ID
            else
            if (Type = const("Update Field")) DMTDataFile.ID
            else
            if (Type = const("Buffer + Target")) DMTDataFile.ID;
            trigger OnValidate()
            var
                CodeUnitMetadata: Record "CodeUnit Metadata";
                DMTDataFile: Record DMTDataFile;
            begin
                case true of
                    (xRec.ID <> 0) and (Rec.ID = 0):
                        Description := '';
                    (Rec.ID <> 0) and (Type in [Type::"Import To Buffer", Type::"Import To Target", Type::"Update Field", Type::"Buffer + Target"]):
                        begin
                            DMTDataFile.Get(Rec.ID);
                            Description := DMTDataFile.Name;
                            "Source Table No." := 0;
                        end;
                    (Rec.ID <> 0) and (Type in [Type::"Run Codeunit"]):
                        begin
                            CodeUnitMetadata.Get(Rec.ID);
                            Description := CodeUnitMetadata.Name;
                        end;
                end;
            end;
        }
        field(12; Description; Text[250]) { Caption = 'Description'; }
        field(30; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table), "App Package ID" = field("Current App Package ID Filter"));
        }
        field(31; "Current App Package ID Filter"; Guid) { Caption = 'Current Package ID Filter', locked = true; FieldClass = FlowFilter; }
        field(32; "Source Table Filter"; Blob) { Caption = 'Source Table Filter Blob', Locked = true; }
        field(33; "Update Fields Filter"; Blob) { Caption = 'Update Fields Filter', Locked = true; }
        field(34; "Default Field Values"; Blob) { Caption = 'Default Field Values', Locked = true; }
        field(40; Status; Option) { Caption = 'Status', Locked = true; OptionMembers = " ","In Progress","Finished"; Editable = false; }
        field(41; StartTime; DateTime) { Caption = 'Start Time'; Editable = false; }
        field(42; "Processing Duration"; Duration) { Caption = 'Processing Duration', Comment = 'de-DE=Verarbeitungszeit'; Editable = false; }
        field(50; Indentation; Integer) { Caption = 'Indentation', Comment = 'de-DE=Einrückung'; Editable = false; }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;
        }
    }

    procedure EditSourceTableFilter()
    var
        DataFile: Record DMTDataFile;
        Import: Codeunit DMTImport;
        BufferRef: RecordRef;
        CurrView: text;
    begin
        if Rec.Type = Rec.Type::"Run Codeunit" then begin
            Rec.TestField("Source Table No.");
            BufferRef.Open(Rec."Source Table No.");
            DataFile.BufferTableType := DataFile.BufferTableType::"Seperate Buffer Table per CSV";
        end else begin
            DataFile.Get(Rec.ID);
            Import.InitBufferRef(DataFile, BufferRef);
        end;
        CurrView := ReadSourceTableView();
        if CurrView <> '' then
            BufferRef.SetView(CurrView);
        if Import.ShowRequestPageFilterDialog(BufferRef, DataFile) then begin
            SaveSourceTableFilter(BufferRef.GetView());
        end;
    end;

    procedure EditDefaultValues()
    var
        DataFile: Record DMTDataFile;
        Import: Codeunit DMTImport;
        TargetRef: RecordRef;
        CurrView: text;
    begin
        DataFile.Get(Rec.ID);
        TargetRef.Open(DataFile."Target Table ID");
        CurrView := ReadDefaultValuesView();
        if CurrView <> '' then
            TargetRef.SetView(CurrView);
        if Import.ShowRequestPageFilterDialog(TargetRef, DataFile) then begin
            SaveDefaultValuesView(TargetRef.GetView());
        end;
    end;

    procedure ReadSourceTableView() SourceTableView: Text
    var
        IStr: InStream;
    begin
        rec.calcfields("Source Table Filter");
        if not rec."Source Table Filter".HasValue then exit('');
        rec."Source Table Filter".CreateInStream(IStr);
        IStr.ReadText(SourceTableView);
    end;

    procedure ReadDefaultValuesView() DefaultValuesView: Text
    var
        IStr: InStream;
    begin
        rec.calcfields("Default Field Values");
        if not rec."Default Field Values".HasValue then exit('');
        rec."Default Field Values".CreateInStream(IStr);
        IStr.ReadText(DefaultValuesView);
    end;

    procedure ReadUpdateFieldsFilter() FilterExpr: Text
    var
        IStr: InStream;
    begin
        rec.calcfields("Update Fields Filter");
        if not rec."Update Fields Filter".HasValue then exit('');
        rec."Update Fields Filter".CreateInStream(IStr);
        IStr.ReadText(FilterExpr);
    end;

    procedure SaveSourceTableFilter(SourceTableView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Source Table Filter");
        Rec.Modify();
        if SourceTableView = '' then
            exit;
        rec."Source Table Filter".CreateOutStream(Ostr);
        OStr.WriteText(SourceTableView);
        Rec.Modify();
    end;

    procedure SaveDefaultValuesView(DefaultValuesView: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Default Field Values");
        Rec.Modify();
        if DefaultValuesView = '' then
            exit;
        rec."Default Field Values".CreateOutStream(Ostr);
        OStr.WriteText(DefaultValuesView);
        Rec.Modify();
    end;

    procedure SaveUpdateFieldsFilter(UpdateFieldsFilter: Text)
    var
        OStr: OutStream;
    begin
        Clear(Rec."Update Fields Filter");
        Rec.Modify();
        if UpdateFieldsFilter = '' then
            exit;
        rec."Update Fields Filter".CreateOutStream(Ostr);
        OStr.WriteText(UpdateFieldsFilter);
        Rec.Modify();
    end;

    procedure CopyToTemp(var TempProcessingPlan: Record DMTProcessingPlan temporary) LineCount: Integer
    var
        ProcessingPlan: Record DMTProcessingPlan;
        TempProcessingPlan2: Record DMTProcessingPlan temporary;
    begin
        ProcessingPlan.Copy(Rec);
        if ProcessingPlan.FindSet(false, false) then
            repeat
                LineCount += 1;
                TempProcessingPlan2 := ProcessingPlan;
                TempProcessingPlan2.Insert(false);
            until ProcessingPlan.Next() = 0;
        TempProcessingPlan.Copy(TempProcessingPlan2, true);
    end;

    procedure CreateSourceTableRef(var SourceRef: RecordRef) Ok: Boolean
    var
        DataFile: Record DMTDataFile;
    begin
        Clear(SourceRef);
        if Rec.ID = 0 then exit(false);
        case Rec.Type of
            rec.Type::"Run Codeunit":
                begin
                    SourceRef.Open(rec."Source Table No.", false);
                    exit(true);
                end;
        end;
        if not DataFile.Get(Rec.ID) then exit;
        if (DataFile."Buffer Table ID" = 0) and (DataFile.BufferTableType = DataFile.BufferTableType::"Generic Buffer Table for all Files") then
            DataFile."Buffer Table ID" := Database::DMTGenBuffTable;
        SourceRef.Open(DataFile."Buffer Table ID", false);
        exit(true)
    end;

    procedure ConvertSourceTableFilterToFieldLines(var TmpFieldMapping: Record DMTFieldMapping temporary)
    var
        TmpFieldMapping2: Record DMTFieldMapping temporary;
        RecRef: RecordRef;
        FieldIndexNo: Integer;
        CurrView: Text;
    begin
        if not Rec.CreateSourceTableRef(RecRef) then
            exit;
        CurrView := Rec.ReadSourceTableView();
        if CurrView <> '' then begin
            RecRef.SetView(CurrView);
            if RecRef.HasFilter then
                for FieldIndexNo := 1 To RecRef.FieldCount do begin
                    if RecRef.FieldIndex(FieldIndexNo).GetFilter <> '' then begin
                        TmpFieldMapping2."Data File ID" := Rec.ID;
                        TmpFieldMapping2."Target Field No." := RecRef.FieldIndex(FieldIndexNo).Number;
                        TmpFieldMapping2."Source Field Caption" := RecRef.FieldIndex(FieldIndexNo).Caption;
                        TmpFieldMapping2.Comment := CopyStr(RecRef.FieldIndex(FieldIndexNo).GetFilter, 1, MaxStrLen(TmpFieldMapping2.Comment));
                        TmpFieldMapping2.Insert();
                    end;
                end;
        end;

        TmpFieldMapping.Copy(TmpFieldMapping2, true);
    end;

    procedure ConvertDefaultValuesViewToFieldLines(var TmpFieldMapping: Record DMTFieldMapping temporary) LineCount: Integer
    var
        TmpFieldMapping2: Record DMTFieldMapping temporary;
        FieldMapping: Record DMTFieldMapping;
        RecRef: RecordRef;
        FieldIndexNo: Integer;
        CurrView: Text;
    begin
        if not Rec.CreateSourceTableRef(RecRef) then exit;
        CurrView := Rec.ReadDefaultValuesView();
        if CurrView <> '' then begin
            RecRef.SetView(CurrView);
            if RecRef.HasFilter then
                for FieldIndexNo := 1 To RecRef.FieldCount do begin
                    if RecRef.FieldIndex(FieldIndexNo).GetFilter <> '' then begin
                        FieldMapping.Get(Rec.ID, RecRef.FieldIndex(FieldIndexNo).Number);
                        TmpFieldMapping2 := FieldMapping;
                        TmpFieldMapping2."Processing Action" := TmpFieldMapping2."Processing Action"::FixedValue;
                        TmpFieldMapping2."Fixed Value" := CopyStr(RecRef.FieldIndex(FieldIndexNo).GetFilter, 1, MaxStrLen(TmpFieldMapping2."Fixed Value"));
                        TmpFieldMapping2.Insert();
                    end;
                end;
        end;

        TmpFieldMapping.Copy(TmpFieldMapping2, true);
        LineCount := TmpFieldMapping.Count;
    end;

    procedure ConvertUpdateFieldsListToFieldLines(var TmpFieldMapping: Record DMTFieldMapping temporary) LineCount: Integer
    var
        DataFile: Record DMTDataFile;
        FieldMapping: Record DMTFieldMapping;
        TmpFieldMapping2: Record DMTFieldMapping temporary;
        RecRef: RecordRef;
        FieldNoFilter: Text;
    begin
        if not Rec.CreateSourceTableRef(RecRef) then exit;
        if not DataFile.Get(Rec.ID) then exit;

        FieldNoFilter := Rec.ReadUpdateFieldsFilter();
        if FieldNoFilter <> '' then begin
            DataFile.FilterRelated(FieldMapping);
            FieldMapping.Setfilter("Target Field No.", FieldNoFilter);
            if FieldMapping.FindSet(false, false) then
                repeat
                    TmpFieldMapping2 := FieldMapping;
                    TmpFieldMapping2.Insert();
                until FieldMapping.Next() = 0;
        end;

        TmpFieldMapping.Copy(TmpFieldMapping2, true);
        LineCount := TmpFieldMapping.Count;
    end;

    procedure ApplySourceTableFilter(var Ref: RecordRef) OK: Boolean
    begin
        OK := true;
        if Rec.ReadSourceTableView() = '' then exit(false);
        Ref.SetView(Rec.ReadSourceTableView());
    end;

    internal procedure InitFlowFilters()
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        mI: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(mI);
        NAVAppInstalledApp.SetRange("App ID", mI.Id);
        NAVAppInstalledApp.FindFirst();
        Rec.SetRange("Current App Package ID Filter", NAVAppInstalledApp."Package ID");
    end;

    procedure TypeSupportsSourceTableFilter(): Boolean
    begin
        exit(Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Run Codeunit", Rec.Type::"Buffer + Target"]);
    end;

    procedure TypeSupportsProcessSelectedFieldsOnly(): Boolean
    begin
        exit(Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target"]);
    end;

    procedure TypeSupportsFixedValues(): Boolean
    begin
        exit(Rec.Type in [Rec.Type::"Import To Target", Rec.Type::"Update Field", Rec.Type::"Buffer + Target"]);
    end;

}