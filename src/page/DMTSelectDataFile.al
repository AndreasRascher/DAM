page 73018 DMTSelectDataFile
{
    Caption = 'Select Data Files', Comment = 'Dateien auswählen';
    PageType = List;
    UsageCategory = None;
    SourceTable = DMTDataFileBuffer;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("DateTime") order(descending);

    layout
    {
        area(Content)
        {
            field(HasSchema; Format(IsNAVSchemaFileImported())) { Caption = 'Schema Data Found'; ApplicationArea = All; }
            repeater(repeater)
            {
                field(Name; Rec.Name) { ApplicationArea = All; StyleExpr = LineStyle; }
                field("DateTime"; Rec."DateTime") { ApplicationArea = All; }
                field("NAV Src.Table No."; Rec."NAV Src.Table No.")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyle;
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DMTObjMgt: Codeunit DMTObjMgt;
                        NAVSrcTableNo: Integer;
                        NAVSrcTableCaption: Text;
                    begin
                        if DMTObjMgt.LookUpOldVersionTable(NAVSrcTableNo, NAVSrcTableCaption) then begin
                            Rec."NAV Src.Table No." := NAVSrcTableNo;
                            Rec."NAV Src.Table Caption" := CopyStr(NAVSrcTableCaption, 1, MaxStrLen(Rec."NAV Src.Table Caption"));
                        end;
                    end;
                }
                field("Target Table ID"; Rec."Target Table ID") { ApplicationArea = All; StyleExpr = LineStyle; ShowMandatory = true; }
                field("NAV Src.Table Caption"; Rec."NAV Src.Table Caption") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
                field("Target Table Caption"; Rec."Target Table Caption") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
                field("NAV Src.Table Name"; Rec."NAV Src.Table Name") { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
                field(Path; Rec.Path) { ApplicationArea = All; Visible = false; StyleExpr = LineStyle; }
                field(Size; Rec.Size) { ApplicationArea = All; StyleExpr = LineStyle; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // action(ActionName)
            // {
            //     ApplicationArea = All;

            //     trigger OnAction()
            //     begin

            //     end;
            // }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.LoadFiles();
    end;

    trigger OnAfterGetRecord()
    begin
        LineStyle := Format(Enum::DMTFieldStyle::None);
        if Rec."File is already assigned" then
            LineStyle := Format(Enum::DMTFieldStyle::Grey)
        else
            LineStyle := Format(Enum::DMTFieldStyle::Bold);
    end;

    procedure GetSelection(var DataFileBuffer_Selected: Record DMTDataFileBuffer temporary) HasLines: Boolean
    var
        TempDataFileBuffer: Record DMTDataFileBuffer temporary;
    begin
        Clear(DataFileBuffer_Selected);
        if DataFileBuffer_Selected.IsTemporary then
            DataFileBuffer_Selected.DeleteAll();

        TempDataFileBuffer.Copy(Rec, true);
        CurrPage.SetSelectionFilter(TempDataFileBuffer);
        if TempDataFileBuffer.FindSet() then
            repeat
                DataFileBuffer_Selected := TempDataFileBuffer;
                DataFileBuffer_Selected.Insert();
            until TempDataFileBuffer.Next() = 0;
        HasLines := DataFileBuffer_Selected.FindFirst();
    end;

    procedure IsNAVSchemaFileImported(): Boolean
    var
        DMTFieldBuffer: Record DMTFieldBuffer;
    begin
        exit(not DMTFieldBuffer.IsEmpty);
    end;

    var
        LineStyle: Text;
}