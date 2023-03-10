page 110001 DMTDocMigrations
{
    Caption = 'DMT Document Migrations';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = DMTDocMigration;
    AutoSplitKey = true;
    SourceTableView = sorting("Line No.");

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                IndentationControls = Description;
                IndentationColumn = Rec.Indentation;
                field("Line No."; Rec."Line No.") { }
                field("Line Type"; Rec."Line Type") { }
                field(Description; Rec.Description)
                {
                    TableRelation = if ("Line Type" = const("Table")) DMTDataFile;
                    StyleExpr = LineStyle;
                    trigger OnAfterLookup(Selected: RecordRef)
                    var
                        DataFile: Record DMTDataFile;
                    begin
                        if Rec."Line Type" = Rec."Line Type"::"Table" then begin
                            Selected.SetTable(DataFile);
                            DataFile.Calcfields("Target Table Caption");
                            Rec.Description := DataFile."Target Table Caption";
                            Rec."Table ID" := DataFile."Target Table ID";
                            Rec."DataFile ID" := DataFile."ID";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        DataFile: Record DMTDataFile;
                    begin
                        if (Rec."Line Type" = Rec."Line Type"::"Table") then begin
                            if Rec.Description <> '' then
                                if DataFile.Get(Rec."DataFile ID") then begin
                                    DataFile.CalcFields("Target Table Caption");
                                    Rec.Description := DataFile."Target Table Caption";
                                end;
                        end;
                        EnableControls();
                        SetLineStyle();
                    end;
                }
                field("Table ID"; Rec."Table ID") { Enabled = IsEnabled_TableNo; }
                field(DeleteRecordIfExits; Rec.DeleteRecordIfExits) { Enabled = (Rec."Line Type" = Rec."Line Type"::Table); }
                field(TableRelations; GetTableRelationsPreview(Rec))
                {
                    Caption = 'Settings';
                    trigger OnDrillDown()
                    var
                        TempDocMigration: Record DMTDocMigration temporary;
                        TableRelation: page DMTTableRelation;
                    begin
                        if Rec."Related Table ID" <> 0 then begin
                            Rec.LoadTableRelation(TempDocMigration);
                            TableRelation.InitTableRelationView(Rec."Table ID", Rec."Related Table ID", TempDocMigration);
                            if TableRelation.RunModal() = Action::OK then begin
                                Rec.SaveTableRelation(TempDocMigration);
                            end;
                        end;
                    end;
                }
                field(Filter; Rec.GetTableFilterDescr())
                {
                    Caption = 'Filter';
                    trigger OnDrillDown()
                    begin
                        Rec.EditTableFilter();
                    end;
                }
                field("Attached to Structure Line No."; Rec."Attached to Structure Line No.") { }
                field("Attached to Line No."; Rec."Attached to Line No.") { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(IndentLeft)
            {
                Caption = 'Indent Left', comment = 'de-DE=Links einrücken';
                ApplicationArea = All;
                Image = DecreaseIndent;
                // Promoted = true;
                // PromotedOnly = true;
                // PromotedCategory = Category4;

                trigger OnAction()
                begin
                    GetSelection(TempDMTDocMigration_SELECTED);
                    Rec.IndentSelectedLines(TempDMTDocMigration_SELECTED, -1);
                    CurrPage.Update(false);
                end;
            }
            action(IndentRight)
            {
                Caption = 'Indent Right', comment = 'de-DE=Rechts einrücken';
                ApplicationArea = All;
                Image = Indent;
                // Promoted = true;
                // PromotedOnly = true;
                // PromotedCategory = Category4;

                trigger OnAction()
                begin
                    GetSelection(TempDMTDocMigration_SELECTED);
                    Rec.IndentSelectedLines(TempDMTDocMigration_SELECTED, +1);
                    CurrPage.Update(false);
                end;
            }
            action(StartProcessingStructure)
            {
                Caption = 'Start';
                Image = Start;
                ApplicationArea = All;
                trigger OnAction()
                var
                    RunDocMigration: Codeunit DMTRunDocMigration;
                begin
                    RunDocMigration.setDocMigrationStructure(Rec);
                    RunDocMigration.Run();
                end;
            }
        }
        area(Promoted)
        {
            group(IndentationGroup)
            {
                Caption = 'Indentation';
                Image = TransferOrder;
                actionref(IndentLeftRef; IndentLeft) { }
                actionref(IndentRightRef; IndentRight) { }
            }
            actionref(Start; StartProcessingStructure) { }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetLineStyle();
        EnableControls();
    end;

    procedure GetSelection(var TempDMTDocMigration_SelectedNew: Record DMTDocMigration temporary) HasLines: Boolean
    var
        DocMigration: Record DMTDocMigration;
        Debug: Integer;
    begin
        Clear(TempDMTDocMigration_SelectedNew);
        if TempDMTDocMigration_SelectedNew.IsTemporary then
            TempDMTDocMigration_SelectedNew.DeleteAll();

        DocMigration.Copy(Rec); // if all fields are selected, no filter is applied but the view is also not applied
        CurrPage.SetSelectionFilter(DocMigration);
        Debug := DocMigration.Count;
        DocMigration.CopyToTemp(TempDMTDocMigration_SelectedNew);
        HasLines := TempDMTDocMigration_SelectedNew.FindFirst();
    end;

    procedure EnableControls()
    begin
        DeleteRecordIfExitsEnabled := Rec."Line Type" = Rec."Line Type"::Table;
        IsEnabled_TableNo := (Rec."Line Type" = Rec."Line Type"::Table);
    end;

    procedure GetTableRelationsPreview(DocMigration: Record DMTDocMigration) PreviewText: Text
    var
        tempDocMigration: Record DMTDocMigration temporary;
    begin
        Rec.LoadTableRelation(tempDocMigration);
        if tempDocMigration.FindSet() then
            repeat
                tempDocMigration.CalcFields("Field Caption", "Related Field Caption");
                PreviewText += StrSubstNo('%1=%2,', tempDocMigration."Field Caption", tempDocMigration."Related Field Caption");
            until tempDocMigration.Next() = 0;
        PreviewText := PreviewText.TrimEnd(',');
    end;

    local procedure SetLineStyle()
    begin
        LineStyle := Format(Enum::DMTFieldStyle::Standard);
        case Rec."Line Type" of
            Rec."Line Type"::Structure:
                LineStyle := Format(Enum::DMTFieldStyle::Bold);
            Rec."Line Type"::Table:
                LineStyle := Format(Enum::DMTFieldStyle::Standard);
        end;
    end;

    var
        TempDMTDocMigration_SELECTED: Record DMTDocMigration temporary;
        LineStyle: Text;
        DeleteRecordIfExitsEnabled: Boolean;
        IsEnabled_TableNo: Boolean;
}