page 91005 DAMSelectTables
{
    CaptionML = DEU = 'Tabellen', ENU = 'Tables';
    PageType = List;
    SourceTable = AllObjWithCaption;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Object ID"; Rec."Object ID") { ApplicationArea = All; }
                field("Object Caption"; Rec."Object Caption") { ApplicationArea = All; }
                field("Object Name"; Rec."Object Name") { ApplicationArea = All; }
            }

        }
    }
    procedure Set(var AllObjWithCaption: Record AllObjWithCaption temporary);
    begin
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
        allObjWithCaption: Record AllObjWithCaption temporary;
        allObjWithCaption2: Record AllObjWithCaption temporary;
        debug: Integer;
    begin
        CurrPage.SetSelectionFilter(Rec);
        debug := Rec.Count;
        if not Rec.FindSet() then exit(false);
        repeat
            allObjWithCaption := Rec;
            allObjWithCaption.Insert(false);
        until Rec.Next() = 0;
        allObjWithCaption_SELECTED.Copy(allObjWithCaption, true);
        debug := allObjWithCaption_SELECTED.Count;
        HasLines := allObjWithCaption_SELECTED.FindFirst();
    end;

}
