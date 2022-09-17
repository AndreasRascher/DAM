page 110010 "DMTSelectTableList"
{
    Caption = 'Tables', Comment = 'Tabellen';
    PageType = List;
    SourceTable = AllObjWithCaption;
    SourceTableTemporary = true;
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Object ID"; Rec."Object ID") { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Object Caption"; Rec."Object Caption") { ApplicationArea = All; StyleExpr = LineStyle; }
                field("Object Name"; Rec."Object Name") { ApplicationArea = All; StyleExpr = LineStyle; }
                field(ObjectStatus; format(ObjectStatus)) { ApplicationArea = All; Caption = 'Object Status', comment = 'Objektstatus'; StyleExpr = LineStyle; }
            }

        }
    }
    procedure Set(var AllObjWithCaption: Record AllObjWithCaption temporary; ObjectPendingStatus: Boolean);
    begin
        ObjectPendingStatusVisible := not ObjectPendingStatus;
        if Rec.IsTemporary then begin
            Clear(Rec);
            Rec.DeleteAll(false);
        end;

        If AllObjWithCaption.FindSet() then
            repeat
                Rec := AllObjWithCaption;
                Rec.Insert(false);
            until AllObjWithCaption.Next() = 0;
        if Rec.FindFirst() then;
    end;

    procedure GetSelection(var allObjWithCaption_SELECTED: Record AllObjWithCaption temporary) HasLines: Boolean
    var
        tempAllObjWithCaption: Record AllObjWithCaption temporary;
        debug: Integer;
    begin
        CurrPage.SetSelectionFilter(Rec);
        debug := Rec.Count;
        if not Rec.FindSet() then exit(false);
        repeat
            tempAllObjWithCaption := Rec;
            tempAllObjWithCaption.Insert(false);
        until Rec.Next() = 0;
        allObjWithCaption_SELECTED.Copy(tempAllObjWithCaption, true);
        debug := allObjWithCaption_SELECTED.Count;
        HasLines := allObjWithCaption_SELECTED.FindFirst();
    end;

    trigger OnAfterGetRecord()
    begin
        LineStyle := Format(Enum::DMTFieldStyle::None);
        ObjectStatus := ObjectStatus::" ";
        if Rec."Object Subtype".Contains('TableExists') then begin
            LineStyle := Format(Enum::DMTFieldStyle::Bold);
        end;
        if Rec."Object Subtype".Contains('Pending') then begin
            LineStyle := Format(Enum::DMTFieldStyle::Yellow);
            ObjectStatus := ObjectStatus::"ObsoleteState:Pending";
        end;
        if Rec."Object Subtype".Contains('Removed') then begin
            LineStyle := Format(Enum::DMTFieldStyle::"Red + Italic");
            ObjectStatus := ObjectStatus::"ObsoleteState:Removed";
        end;
    end;

    var
        [InDataSet]
        LineStyle: Text[15];
        ObjectStatus: Option " ","ObsoleteState:Pending","ObsoleteState:Removed";
        [InDataSet]
        ObjectPendingStatusVisible: Boolean;
}
