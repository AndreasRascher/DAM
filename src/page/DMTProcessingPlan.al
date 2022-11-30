page 110015 DMTProcessingPlan
{
    Caption = 'DMT Processing Plan', Comment = 'de-DE Verarbeitungsplan';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = DMTProcessingPlan;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater("Repeater")
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = Description;
                field("Line Type"; Rec.Type) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(DataFileID; Rec.ID) { ApplicationArea = All; StyleExpr = LineStyle; BlankZero = true; }
                field(Description; Rec.Description) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ProcessingTime; Rec."Processing Duration") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(StartTime; Rec.StartTime) { ApplicationArea = All; StyleExpr = LineStyle; }
                field(Status; Rec.Status) { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
            }
        }
        area(FactBoxes)
        {
            part(SourceTableFilter; "DMTProcessInstructionFactBox")
            {
                Caption = 'Source Table Filter';
                UpdatePropagation = Both;
            }
            part(FixedValues; "DMTProcessInstructionFactBox")
            {
                Caption = 'Fields';
                UpdatePropagation = Both;
            }
        }
    }


    actions
    {
        area(Processing)
        {
            action(Start)
            {
                Caption = 'Start', comment = 'de-DE Ausführen';
                ApplicationArea = All;
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    RunSelected(ProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
            action(IndentLeft)
            {
                Caption = 'Indent Left', comment = 'Links einrücken';
                ApplicationArea = All;
                Image = PreviousRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    IndentLines(ProcessingPlan_SELECTED, -1);
                    CurrPage.Update(false);
                end;
            }
            action(IndentRight)
            {
                Caption = 'Indent Right', comment = 'Rechts einrücken';
                ApplicationArea = All;
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    IndentLines(ProcessingPlan_SELECTED, +1);
                    CurrPage.Update(false);
                end;
            }
            action(ResetLines)
            {
                Caption = 'Reset Lines', comment = 'Zeilen zurücksetzen';
                ApplicationArea = All;
                Image = NextRecord;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    GetSelection(ProcessingPlan_SELECTED);
                    ResetLines(ProcessingPlan_SELECTED);
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        LineStyle := '';
    end;

    trigger OnAfterGetRecord()
    begin
        LineStyle := '';
        case true of
            (Rec.Type = Rec.Type::Group):
                LineStyle := format(Enum::DMTFieldStyle::Bold);
            (Rec.Status = Rec.Status::"In Progress"):
                LineStyle := format(Enum::DMTFieldStyle::Yellow);
            (Rec.Status = Rec.Status::Finished):
                LineStyle := format(Enum::DMTFieldStyle::"Bold + Green");
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.SourceTableFilter.Page.InitFactBoxAsSourceTableFilter(Rec);
        CurrPage.FixedValues.Page.InitFactBoxAsFixedValueView(Rec);
    end;

    local procedure RunSelected(var ProcessingPlan_SELECTED: Record DMTProcessingPlan temporary)
    var
        DMTDataFile: Record DMTDataFile;
        ProcessingPlan: record DMTProcessingPlan;
        PageAction: Codeunit DMTDataFilePageAction;
        Success: Boolean;
    begin
        if not ProcessingPlan_SELECTED.FindSet then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            ProcessingPlan.TestField(ID);
            case ProcessingPlan.Type of
                DMTProcessingPlanType::" ", DMTProcessingPlanType::"Group":
                    ;
                DMTProcessingPlanType::"Import To Buffer":
                    begin
                        SetStatusToStart(ProcessingPlan);
                        DMTDataFile.Get(ProcessingPlan.ID);
                        DMTDataFile.SetRecFilter();
                        PageAction.ImportToBufferTable(DMTDataFile, false);
                        Commit();
                    end;
                DMTProcessingPlanType::"Import To Target":
                    begin
                        SetStatusToStart(ProcessingPlan);
                        DMTDataFile.Get(ProcessingPlan.ID);
                        DMTDataFile.WriteSourceTableView(Rec.ReadSourceTableView());
                        DMTDataFile.SetRecFilter();
                        PageAction.ImportSelectedIntoTarget(DMTDataFile);
                        Commit();
                    end;
                DMTProcessingPlanType::"Run Codeunit":
                    begin
                        SetStatusToStart(ProcessingPlan);
                        Commit();
                        ClearLastError();
                        Success := Codeunit.Run(ProcessingPlan.ID);
                        if GetLastErrorText() <> '' then
                            Message(GetLastErrorText());
                    end;
                DMTProcessingPlanType::"Update Field":
                    begin
                        Error('ToDo');
                        SetStatusToStart(ProcessingPlan);
                        Commit();
                    end;
            end;
            ProcessingPlan."Processing Duration" := CurrentDateTime - ProcessingPlan.StartTime;
            ProcessingPlan.Status := ProcessingPlan.Status::Finished;
            ProcessingPlan.Modify();
            Commit();
        until ProcessingPlan_SELECTED.Next() = 0;
    end;

    local procedure ResetLines(var ProcessingPlan_SELECTED: Record DMTProcessingPlan temporary)
    var
        ProcessingPlan: record DMTProcessingPlan;
    begin
        if not ProcessingPlan_SELECTED.FindSet then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            Clear(ProcessingPlan.Status);
            Clear(ProcessingPlan.StartTime);
            Clear(ProcessingPlan."Processing Duration");
            ProcessingPlan.Modify();
            Commit();
        until ProcessingPlan_SELECTED.Next() = 0;
    end;

    local procedure SetStatusToStart(var ProcessingPlan: record DMTProcessingPlan)
    begin
        ProcessingPlan.StartTime := CurrentDateTime;
        ProcessingPlan.Status := ProcessingPlan.Status::"In Progress";
        ProcessingPlan.Modify();
    end;

    procedure GetSelection(var TempProcessingPlan_Selected: Record DMTProcessingPlan temporary) HasLines: Boolean
    var
        ProcessingPlan: Record DMTProcessingPlan;
        Debug: Integer;
    begin
        Clear(TempProcessingPlan_Selected);
        if TempProcessingPlan_Selected.IsTemporary then
            TempProcessingPlan_Selected.DeleteAll();

        ProcessingPlan.Copy(rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(ProcessingPlan);
        Debug := ProcessingPlan.Count;
        ProcessingPlan.CopyToTemp(TempProcessingPlan_Selected);
        HasLines := TempProcessingPlan_Selected.FindFirst();
    end;

    internal procedure IndentLines(var TempProcessingPLan: Record DMTProcessingPlan temporary; Direction: Integer)
    var
        ProcessingPlan: record DMTProcessingPlan;
    begin
        if not TempProcessingPLan.FindSet() then exit;
        repeat
            ProcessingPlan.Get(ProcessingPlan_SELECTED.RecordId);
            ProcessingPlan.Indentation += Direction;
            if ProcessingPlan.Indentation < 0 then
                ProcessingPlan.Indentation := 0;
            ProcessingPlan.Modify()
        until TempProcessingPLan.Next() = 0;
    end;

    var
        ProcessingPlan_SELECTED: record DMTProcessingPlan temporary;
        LineStyle: Text;
}