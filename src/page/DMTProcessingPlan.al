page 110015 DMTProcessingPlan
{
    Caption = 'DMT Processing Plan', Comment = 'de-DE=DMT Verarbeitungsplan';
    AdditionalSearchTerms = 'DMT Plan';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTProcessingPlan;
    AutoSplitKey = true;
    // Report = Backup
    // Category4 = Arrange
    PromotedActionCategories = 'New,Process,Backup,Arrange,Category5,Category6,Category7,Category8,Category9,Category10,Category11,Category12,Category13,Category14,Category15,Category16,Category17,Category18,Category19,Category20';
    layout
    {
        area(Content)
        {
            repeater(EditRepeater)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = DescriptionEdit;
                Visible = not ShowTreeView;
                field(LineTypeEdit; Rec.Type) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(DataFileIDEdit; Rec.ID) { ApplicationArea = All; StyleExpr = LineStyle; BlankZero = true; }
                field(DescriptionEdit; Rec.Description) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ProcessingTimeEdit; Rec."Processing Duration") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(StartTimeEdit; Rec.StartTime) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(StatusEdit; Rec.Status) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(SourceTableNoEdit; Rec."Source Table No.") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(LineNoEdit; Rec."Line No.") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
            }
            repeater("Repeater")
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                ShowAsTree = true;
                Visible = ShowTreeView;
                field("Line Type"; Rec.Type) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(DataFileID; Rec.ID) { ApplicationArea = All; StyleExpr = LineStyle; BlankZero = true; }
                field(Description; Rec.Description) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ProcessingTime; Rec."Processing Duration") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(StartTime; Rec.StartTime) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Source Table No."; Rec."Source Table No.") { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
            }
        }
        area(FactBoxes)
        {
            part(SourceTableFilter; DMTProcessInstructionFactBox)
            {
                Caption = 'Source Table Filter', Comment = 'de-DE=Quelldaten Filter';
                SubPageLink = "Data File ID" = field(ID);
                UpdatePropagation = Both;
                Enabled = ShowSourceTableFilterPart;
            }
            part(FixedValues; DMTProcessInstructionFactBox)
            {
                Caption = 'Default Values', Comment = 'de-DE=Vorgabewerte';
                SubPageLink = "Data File ID" = field(ID);
                UpdatePropagation = Both;
                Enabled = ShowFixedValuesPart;
            }
            part(ProcessSelectedFieldsOnly; DMTProcessInstructionFactBox)
            {
                Caption = 'Process selected fields only', Comment = 'de-DE=Ausgew. Felder verarbeiten';
                SubPageLink = "Data File ID" = field(ID);
                UpdatePropagation = Both;
                Enabled = ShowProcessSelectedFieldsOnly;
            }
        }
    }


    actions
    {
        area(Processing)
        {
            action(Start)
            {
                Caption = 'Start', comment = 'de-DE=Ausführen';
                ApplicationArea = All;
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    RunSelected(TempProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
            action(IndentLeft)
            {
                Caption = 'Indent Left', comment = 'de-DE=Links einrücken';
                ApplicationArea = All;
                Image = PreviousRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    IndentLines(TempProcessingPlan_SELECTED, -1);
                    CurrPage.Update(false);
                end;
            }
            action(IndentRight)
            {
                Caption = 'Indent Right', comment = 'de-DE=Rechts einrücken';
                ApplicationArea = All;
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;

                trigger OnAction()
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    IndentLines(TempProcessingPlan_SELECTED, +1);
                    CurrPage.Update(false);
                end;
            }
            action(ResetLinesAction)
            {
                Caption = 'Reset Lines', comment = 'de-DE=Zeilen zurücksetzen';
                ApplicationArea = All;
                Image = Restore;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    GetSelection(TempProcessingPlan_SELECTED);
                    ResetLines(TempProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
            action(RenumberLinesAction)
            {
                Caption = 'Renumber Lines', comment = 'de-DE=Zeilen neu nummerieren';
                ApplicationArea = All;
                Image = NumberGroup;
                trigger OnAction()
                begin
                    RenumberLines()
                end;
            }
            action(XMLExport)
            {
                Caption = 'Create Backup', Comment = 'Backup erstellen';
                ApplicationArea = All;
                Image = CreateXMLFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    TableMetadata: Record "Table Metadata";
                    XMLBackup: Codeunit DMTXMLBackup;
                    TablesToExport: List of [Integer];
                begin
                    TableMetadata.Get(Database::DMTProcessingPlan);
                    TablesToExport.Add(Database::DMTProcessingPlan);
                    XMLBackup.Export(TablesToExport, TableMetadata.Caption);
                end;
            }
            action(XMLImport)
            {
                Caption = 'Import Backup', Comment = 'Backup importieren';
                ApplicationArea = All;
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Report;

                trigger OnAction()
                var
                    DataFile: Record DMTDataFile;
                    PageActions: Codeunit DMTDataFilePageAction;
                    XMLBackup: Codeunit DMTXMLBackup;
                begin
                    XMLBackup.Import();
                    // Update imported "Qty.Lines In Trgt. Table" with actual values
                    if DataFile.FindSet() then
                        repeat
                            PageActions.UpdateQtyLinesInBufferTable(DataFile);
                        until DataFile.Next() = 0;
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        LineStyle := '';
        ShowTreeView := not CurrPage.Editable;
    end;

    trigger OnAfterGetRecord()
    begin
        ShowTreeView := not CurrPage.Editable;
        Rec.InitFlowFilters();
        LineStyle := '';
        case true of
            (Rec.Type = Rec.Type::Group):
                LineStyle := Format(Enum::DMTFieldStyle::Bold);
            (Rec.Status = Rec.Status::"In Progress"):
                LineStyle := Format(Enum::DMTFieldStyle::Yellow);
            (Rec.Status = Rec.Status::Finished):
                LineStyle := Format(Enum::DMTFieldStyle::"Bold + Green");
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateVisibility();
        CurrPage.SourceTableFilter.Page.InitFactBoxAsSourceTableFilter(Rec);
        CurrPage.FixedValues.Page.InitFactBoxAsFixedValueView(Rec);
        CurrPage.ProcessSelectedFieldsOnly.Page.InitFactBoxAsUpdateSelectedFields(Rec);
    end;

    local procedure RunSelected(var ProcessingPlan_SELECTED: Record DMTProcessingPlan temporary)
    var
        DMTDataFile: Record DMTDataFile;
        ProcessingPlan: Record DMTProcessingPlan;
        ProcessStorage: Codeunit DMTProcessStorage;
        PageAction: Codeunit DMTDataFilePageAction;
        Success: Boolean;
    begin
        if not ProcessingPlan_SELECTED.FindSet() then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            ProcessingPlan.TestField(ID);
            case ProcessingPlan.Type of
                DMTProcessingPlanType::" ", DMTProcessingPlanType::"Group":
                    ;
                DMTProcessingPlanType::"Import To Buffer":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        DMTDataFile.Get(ProcessingPlan.ID);
                        DMTDataFile.SetRecFilter();
                        PageAction.ImportToBufferTable(DMTDataFile, false);
                    end;
                DMTProcessingPlanType::"Import To Target":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        PageAction.ImportWithProcessingPlanParams(ProcessingPlan);
                    end;
                DMTProcessingPlanType::"Run Codeunit":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        ClearLastError();
                        ProcessStorage.Set(ProcessingPlan);
                        Success := Codeunit.Run(ProcessingPlan.ID);
                        if GetLastErrorText() <> '' then
                            Message(GetLastErrorText());
                    end;
                DMTProcessingPlanType::"Update Field":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        PageAction.ImportWithProcessingPlanParams(ProcessingPlan);
                    end;
                DMTProcessingPlanType::"Buffer + Target":
                    begin
                        SetStatusToStartAndCommit(ProcessingPlan);
                        DMTDataFile.Get(ProcessingPlan.ID);
                        DMTDataFile.SetRecFilter();
                        PageAction.ImportToBufferTable(DMTDataFile, false);
                        PageAction.ImportWithProcessingPlanParams(ProcessingPlan);
                    end;
            end;
            ProcessingPlan."Processing Duration" := CurrentDateTime - ProcessingPlan.StartTime;
            ProcessingPlan.Status := ProcessingPlan.Status::Finished;
            ProcessingPlan.Modify();
            Commit();
            ProcessStorage.Unbind();
        until ProcessingPlan_SELECTED.Next() = 0;
    end;

    local procedure ResetLines(var ProcessingPlan_SELECTED_NEW: Record DMTProcessingPlan temporary)
    var
        ProcessingPlan: Record DMTProcessingPlan;
    begin
        if not ProcessingPlan_SELECTED_NEW.FindSet() then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED_NEW.RecordId);
            Clear(ProcessingPlan.Status);
            Clear(ProcessingPlan.StartTime);
            Clear(ProcessingPlan."Processing Duration");
            ProcessingPlan.Modify();
            Commit();
        until ProcessingPlan_SELECTED_NEW.Next() = 0;
    end;

    local procedure SetStatusToStartAndCommit(var ProcessingPlan: Record DMTProcessingPlan)
    begin
        ProcessingPlan.StartTime := CurrentDateTime;
        ProcessingPlan.Status := ProcessingPlan.Status::"In Progress";
        ProcessingPlan.Modify();
        Commit();
    end;

    local procedure RenumberLines()
    var
        ProcessingPlan: Record DMTProcessingPlan;
        LineNoMapping: Dictionary of [Integer, Integer];
        OldLineNo, NewLineNo : Integer;
    begin
        if not ProcessingPlan.FindSet() then exit;
        //Create Mapping
        repeat
            NewLineNo += 10000;
            LineNoMapping.Add(ProcessingPlan."Line No.", NewLineNo);
        until ProcessingPlan.Next() = 0;
        //Rename Lines
        while LineNoMapping.Count > 0 do begin
            foreach OldLineNo in LineNoMapping.Keys do begin
                // Remove from mapping if same line no
                NewLineNo := LineNoMapping.Get(OldLineNo);
                if OldLineNo = NewLineNo then
                    LineNoMapping.Remove(OldLineNo);
                // Rename Line to free line no, Remove From Mapping
                if not LineNoMapping.Keys.Contains(NewLineNo) then begin
                    ProcessingPlan.Get(OldLineNo);
                    ProcessingPlan.Rename(NewLineNo);
                    LineNoMapping.Remove(OldLineNo);
                end;
            end;
        end;
    end;

    procedure GetSelection(var TempProcessingPlan_SelectedNew: Record DMTProcessingPlan temporary) HasLines: Boolean
    var
        ProcessingPlan: Record DMTProcessingPlan;
        Debug: Integer;
    begin
        Clear(TempProcessingPlan_SelectedNew);
        if TempProcessingPlan_SelectedNew.IsTemporary then
            TempProcessingPlan_SelectedNew.DeleteAll();

        ProcessingPlan.Copy(Rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(ProcessingPlan);
        Debug := ProcessingPlan.Count;
        ProcessingPlan.CopyToTemp(TempProcessingPlan_SelectedNew);
        HasLines := TempProcessingPlan_SelectedNew.FindFirst();
    end;

    internal procedure IndentLines(var TempProcessingPLan: Record DMTProcessingPlan temporary; Direction: Integer)
    var
        ProcessingPlan: Record DMTProcessingPlan;
    begin
        if not TempProcessingPLan.FindSet() then exit;
        repeat
            ProcessingPlan.Get(TempProcessingPlan_SELECTED.RecordId);
            ProcessingPlan.Indentation += Direction;
            if ProcessingPlan.Indentation < 0 then
                ProcessingPlan.Indentation := 0;
            ProcessingPlan.Modify()
        until TempProcessingPLan.Next() = 0;
    end;

    local procedure UpdateVisibility()
    begin
        ShowSourceTableFilterPart := Rec.TypeSupportsSourceTableFilter();
        ShowFixedValuesPart := Rec.TypeSupportsFixedValues();
        ShowProcessSelectedFieldsOnly := Rec.TypeSupportsProcessSelectedFieldsOnly();
    end;

    var
        TempProcessingPlan_SELECTED: Record DMTProcessingPlan temporary;
        [InDataSet]
        ShowFixedValuesPart, ShowProcessSelectedFieldsOnly, ShowSourceTableFilterPart, ShowTreeView : Boolean;
        LineStyle: Text;
}