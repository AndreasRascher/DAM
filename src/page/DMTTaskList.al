page 81134 "DMTTaskList"
{
    CaptionML = DEU = 'DMT Aufgabenliste', ENU = 'DMT Task List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = DMTTask;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field(Type; Rec."Type") { ApplicationArea = All; }
                field(ID; Rec.ID) { ApplicationArea = All; }
                field("Context Description"; Rec."Context Description") { ApplicationArea = All; }
                field(CurrFilter; CurrFilter)
                {
                    CaptionML = DEU = 'Filter', ENU = 'Filter';
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnDrillDown()
                    var
                        DMTTable: Record DMTTable;
                        DMTImport: Codeunit "DMTImport";
                        BufferRef: RecordRef;
                    begin
                        if Rec.Type <> Rec.Type::ImportToTarget then
                            exit;
                        if not Rec.FindRelated(DMTTable) then
                            exit;
                        BufferRef.Open(DMTTable."Buffer Table ID");
                        Commit();
                        if DMTImport.ShowRequestPageFilterDialog(BufferRef, DMTTable) then
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
                    DMTTask_SELECTED: Record DMTTask;
                begin
                    if not GetSelection(DMTTask_SELECTED) then
                        exit;
                    DMTTask_SELECTED.FindSet();
                    repeat
                        RunTask(DMTTask_SELECTED);
                    until DMTTask_SELECTED.Next() = 0;

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

    procedure GetSelection(var DMTTask_SELECTED: Record DMTTask) HasLines: Boolean
    begin
        Clear(DMTTask_SELECTED);
        CurrPage.SetSelectionFilter(DMTTask_SELECTED);
        HasLines := DMTTask_SELECTED.FindFirst();
    end;

    procedure RunTask(DMTTask: Record DMTTask)
    var
        DMTTable: Record DMTTable;
        DMTImport: Codeunit "DMTImport";
        Start: DateTime;
    begin
        case DMTTask.Type of
            dmttask.Type::ImportToBuffer:
                begin
                    If not Rec.FindRelated(DMTTable) then exit;
                    Start := CurrentDateTime;
                    DMTTable.ImportToBufferTable();
                    DMTTask."Processing Time" := CurrentDateTime - Start;
                    DMTTask.Modify();
                end;
            dmttask.Type::ImportToTarget:
                begin
                    If not Rec.FindRelated(DMTTable) then exit;
                    Start := CurrentDateTime;
                    DMTImport.SetBufferTableView(Rec.GetStoredTableView());
                    DMTImport.ProcessFullBuffer(DMTTable);
                    DMTTask.get(DMTTask.RecordId);
                    DMTTask."Processing Time" := CurrentDateTime - Start;
                    DMTTask.Modify();
                end;
            DMTTask.Type::RunCodeunit:
                begin
                    Start := CurrentDateTime;
                    Codeunit.Run(DMTTask.ID);
                    DMTTask."Processing Time" := CurrentDateTime - Start;
                    DMTTask.Modify();
                end;
        end;
    end;

    var
        [InDataSet]
        CurrFilter: text;
}