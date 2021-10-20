page 91006 DAMTaskList
{
    CaptionML = DEU = 'DAM Aufgabeliste', ENU = 'DAM Task List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DAMTask;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field("Type"; Rec."Type") { ApplicationArea = All; }
                field(ID; Rec.ID) { ApplicationArea = All; }
                field("Context Description"; Rec."Context Description") { ApplicationArea = All; }
                field(CurrFilter; CurrFilter)
                {
                    CaptionML = DEU = 'Filter', ENU = 'Filter';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        DAMTable: Record DAMTable;
                        DAMImport: Codeunit DAMImport;
                        BufferRef: RecordRef;
                    begin
                        if Rec.Type <> Rec.Type::ImportToTarget then
                            exit;
                        if not Rec.FindRelated(DAMTable) then
                            exit;
                        BufferRef.Open(DAMTable."Buffer Table ID");
                        Commit();
                        if DAMImport.ShowRequestPageFilterDialog(BufferRef) then
                            Rec.SaveTableView(BufferRef.GetView());
                        CurrFilter := rec.GetStoredTableViewAsFilter();
                    end;
                }
                field("Import Duration (Longest)"; Rec."Processing Time") { ApplicationArea = All; }
                field("No. of Records"; Rec."No. of Records") { ApplicationArea = All; }
                field("No. of Records failed"; Rec."No. of Records failed") { ApplicationArea = All; }
                field("No. of Records imported"; Rec."No. of Records imported") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunSelected)
            {
                CaptionML = DEU = 'Auswahl ausführen', ENU = 'Run Selected';
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Start;

                trigger OnAction()
                var
                    DAMTask_SELECTED: Record DAMTask;
                begin
                    if not GetSelection(DAMTask_SELECTED) then
                        exit;
                    DAMTask_SELECTED.FindSet();
                    repeat
                        RunTask(DAMTask_SELECTED);
                    until DAMTask_SELECTED.Next() = 0;

                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CurrFilter := rec.GetStoredTableViewAsFilter();
    end;

    trigger OnAfterGetRecord()
    begin
        CurrFilter := rec.GetStoredTableViewAsFilter();
    end;

    procedure GetSelection(var DAMTask_SELECTED: Record DAMTask) HasLines: Boolean
    begin
        Clear(DAMTask_SELECTED);
        CurrPage.SetSelectionFilter(DAMTask_SELECTED);
        HasLines := DAMTask_SELECTED.FindFirst();
    end;

    procedure RunTask(DAMTask: Record DAMTask)
    var
        DAMTable: Record DAMTable;
        DAMImport: Codeunit DAMImport;
        Start: DateTime;
    begin
        case DAMTask.Type of
            damtask.Type::ImportToBuffer:
                begin
                    If not Rec.FindRelated(DAMTable) then exit;
                    Start := CurrentDateTime;
                    DAMTable.ImportToBufferTable();
                    DAMTask."Processing Time" := CurrentDateTime - Start;
                    DAMTask.Modify();
                end;
            damtask.Type::ImportToTarget:
                begin
                    If not Rec.FindRelated(DAMTable) then exit;
                    Start := CurrentDateTime;
                    DAMImport.SetBufferTableView(Rec.GetStoredTableView());
                    DAMImport.SetDAMTableToProcess(DAMTable);
                    DAMImport.ProcessFullBuffer();
                    DAMTask.get(DAMTask.RecordId);
                    DAMTask."Processing Time" := CurrentDateTime - Start;
                    DAMTask.Modify();
                end;
            DAMTask.Type::RunCodeunit:
                begin
                    Start := CurrentDateTime;
                    Codeunit.Run(DAMTask.ID);
                    DAMTask."Processing Time" := CurrentDateTime - Start;
                    DAMTask.Modify();
                end;
        end;
    end;

    var
        [InDataSet]
        CurrFilter: text;
}