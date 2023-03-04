page 110013 DMTCopyTableList
{
    Caption = 'DMT Copy Table List', Comment = 'DMT Tabellen kopieren';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTCopyTable;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                FreezeColumn = "Table Caption";
                field("Table No."; Rec."Table No.") { ApplicationArea = All; }
                field("Table Caption"; Rec."Table Caption") { ApplicationArea = All; }
                field(SourceCompany; Rec.SourceCompanyName) { ApplicationArea = All; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; Visible = false; }
                field("Import Only New Records"; Rec."Import Only New Records") { ApplicationArea = All; }
                field(SavedFilter; Rec.FilterText)
                {
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    begin
                        Rec.EditSavedFilters();
                    end;
                }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("No. of Records"; Rec."No. of Records(Target)") { ApplicationArea = All; }
                field("No. of Records imported"; Rec."No. of Records inserted") { ApplicationArea = All; }
                field("Processing Time"; Rec."Processing Time") { ApplicationArea = All; }
            }
        }
        area(FactBoxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(CopyDataFromSourceCompanyAction)
            {
                Caption = 'Copy Tables', Comment = 'Tabellen kopieren';
                Image = Copy;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    GetSelection(TempCopyTable_SELECTED);
                    CopyDataFromSourceCompany(TempCopyTable_SELECTED);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.SetFilter(ExcludeSourceCompanyFilter, '<>%1', CompanyName);
    end;

    local procedure CopyDataFromSourceCompany(var CopyTable_SELECTED: Record DMTCopyTable temporary)
    var
        ProgressDialog: Codeunit DMTProgressDialog;
    begin
        if not CopyTable_SELECTED.FindSet() then exit;
        repeat
            CopyTable_SELECTED.CalcFields("Table Caption");
            ProgressDialog.AppendText(CopyTable_SELECTED."Table Caption");
            ProgressDialog.AddField(10, format(CopyTable_SELECTED."Table No."));
            ProgressDialog.AppendTextLine('');
        until CopyTable_SELECTED.Next() = 0;

        CopyTable_SELECTED.FindSet();
        ProgressDialog.Open();
        repeat
            ProgressDialog.SaveCustomStartTime(format(CopyTable_SELECTED."Table No."));
            CopyDataFromSourceCompanyInner(CopyTable_SELECTED);
            ProgressDialog.UpdateControlWithCustomDuration(format(CopyTable_SELECTED."Table No."), format(CopyTable_SELECTED."Table No."));
        until CopyTable_SELECTED.Next() = 0;
        ProgressDialog.Close();
    end;

    local procedure CopyDataFromSourceCompanyInner(CopyTable: Record DMTCopyTable)
    var
        DMTMgt: Codeunit DMTMgt;
        SourceRef, TargetRef, TargetRef2 : RecordRef;
        RecordExists: Boolean;
        NoOfRecordsInserted: Integer;
    begin
        SourceRef.Open(CopyTable."Table No.", false, CopyTable.SourceCompanyName);
        if CopyTable.LoadTableView() <> '' then
            SourceRef.SetView(CopyTable.LoadTableView());
        TargetRef.Open(CopyTable."Table No.", false, CompanyName);
        if SourceRef.FindSet() then
            repeat
                DMTMgt.CopyRecordRef(SourceRef, TargetRef);
                RecordExists := TargetRef2.Get(TargetRef.RecordId);
                if CopyTable."Import Only New Records" then begin
                    if not RecordExists then begin
                        TargetRef.Insert();
                        NoOfRecordsInserted += 1;
                    end;
                end else begin
                    if not RecordExists then begin
                        TargetRef.Insert();
                        NoOfRecordsInserted += 1;
                    end else begin
                        TargetRef.Modify();
                        NoOfRecordsInserted := 1;
                    end;
                end;
            until SourceRef.Next() = 0;
        // Store Processing Information
        CopyTable."No. of Records inserted" := NoOfRecordsInserted;
        CopyTable."No. of Records(Target)" := TargetRef.Count;
    end;

    procedure GetSelection(var CopyTable_SELECTED: Record DMTCopyTable temporary) HasLines: Boolean
    var
        CopyTable: Record DMTCopyTable;
        Debug: Integer;
    begin
        Clear(CopyTable_SELECTED);
        if CopyTable_SELECTED.IsTemporary then CopyTable_SELECTED.DeleteAll();
        Debug := Rec.Count;
        CopyTable.Copy(Rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(CopyTable);
        Debug := CopyTable.Count;
        CopyTable.CopyToTemp(CopyTable_SELECTED);
        HasLines := CopyTable_SELECTED.FindFirst();
    end;

    var
        TempCopyTable_SELECTED: Record DMTCopyTable temporary;
}