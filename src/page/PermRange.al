// page 81140 PermissionRange
// {
//     PageType = List;
//     ApplicationArea = All;
//     UsageCategory = Administration;
//     SourceTable = "Permission Range";

//     layout
//     {
//         area(Content)
//         {
//             repeater(GroupName)
//             {

//                 field(Index; Rec.Index) { ApplicationArea = All; }
//                 field(From; Rec.From) { ApplicationArea = All; }
//                 field("To"; Rec."To") { ApplicationArea = All; }
//                 field("Delete Permission"; Rec."Delete Permission") { ApplicationArea = All; }
//                 field("Execute Permission"; Rec."Execute Permission") { ApplicationArea = All; }
//                 field("Insert Permission"; Rec."Insert Permission") { ApplicationArea = All; }
//                 field("Limited Usage Permission"; Rec."Limited Usage Permission") { ApplicationArea = All; }
//                 field("Modify Permission"; Rec."Modify Permission") { ApplicationArea = All; }
//                 field("Object Type"; Rec."Object Type") { ApplicationArea = All; }
//                 field("Read Permission"; Rec."Read Permission") { ApplicationArea = All; }
//             }
//         }
//     }
// }

page 50100 FreeObjectsInLicense
{
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTable = AllObjWithCaption;
    PageType = Worksheet;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {

            repeater(Objects)
            {
                field("Object ID"; Rec."Object ID") { ApplicationArea = All; }
                field("Object Name"; Rec."Object Name") { ApplicationArea = All; }
                field("Object Type"; Rec."Object Type") { ApplicationArea = All; }
                field("Object Caption"; Rec."Object Caption") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(GetFreeIDs)
            {
                action(PageIDs)
                {
                    Image = ListPage;
                    trigger OnAction()
                    begin
                        ApplyObjectTypeFilter(Rec."Object Type"::Page);
                    end;
                }
                action(TableIDs)
                {
                    Image = Table;
                    trigger OnAction()
                    begin
                        ApplyObjectTypeFilter(Rec."Object Type"::Table);
                    end;
                }
                action(XMLPorts)
                {
                    Image = XMLFile;
                    trigger OnAction()
                    begin
                        ApplyObjectTypeFilter(Rec."Object Type"::XMLport);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Load();
    end;

    procedure Load()
    var
        permissionRange: Record "Permission Range";
        AllObjWithCaption: Record AllObjWithCaption;
    begin

        AllObjWithCaption := Rec;
        rec.DeleteAll();
        Rec := AllObjWithCaption;
        if SetFilter_RIMDX(permissionRange) = 0 then exit;

        dgDialog.OPEN('Gefundene Objekte #######1#');

        permissionRange.FindSet(false, false);
        REPEAT
            CollectFreeNumberInRange(permissionRange);
            dgDialog.UPDATE(1, COUNT);
        UNTIL permissionRange.Next() = 0;
        dgDialog.Close();

        GetQtyObjetstByType;

        IF rec.FINDFIRST() THEN;
    end;

    procedure SetFilter_RIMDX(var PermRange: Record "Permission Range") LinesFound: Integer;
    begin
        PermRange.RESET();
        PermRange.SETRANGE("Object Type", 1, GetMaxObjectType());
        PermRange.SETRANGE("Read Permission", PermRange."Read Permission"::Yes);
        PermRange.SETRANGE("Insert Permission", PermRange."Insert Permission"::Yes);
        PermRange.SETRANGE("Modify Permission", PermRange."Modify Permission"::Yes);
        PermRange.SETRANGE("Delete Permission", PermRange."Delete Permission"::Yes);
        PermRange.SETRANGE("Execute Permission", PermRange."Execute Permission"::Yes);

        // CASE oFilterRangeSet OF
        //     oFilterRangeSet::"50000..99999":
        //         begin
        //             PermRange.SETRANGE(From, 50000, 99999);
        //             PermRange.SETRANGE("To", 50000, 99999);
        //         end;
        //     oFilterRangeSet::"1..":
        //         begin
        //             PermRange.SETRANGE(From);
        //             PermRange.SETRANGE(Index);
        //         end
        // end;
        LinesFound := PermRange.Count;
    end;

    procedure GetMaxObjectType(): Integer
    begin
        exit(10);
    end;

    procedure GetQtyObjetstByType();
    var
        permissionRange: Record "Permission Range";
        i: Integer;
    begin
        rec.reset();
        iTotal := rec.Count;
        FOR i := 1 TO GetMaxObjectType DO begin
            permissionRange."Object Type" := i;
            rec.SETRANGE("Object Type", i);
            CASE permissionRange."Object Type" OF
                permissionRange."Object Type"::Table:
                    iQtyTable := rec.Count;
                permissionRange."Object Type"::Page:
                    iQtyPages := rec.Count;
                permissionRange."Object Type"::Report:
                    iQtyReport := rec.Count;
                permissionRange."Object Type"::Codeunit:
                    iQtyCodeunits := rec.Count;
                permissionRange."Object Type"::Query:
                    iQtyQueries := rec.Count;
                permissionRange."Object Type"::XMLport:
                    iQtyXMLport := rec.Count;
            end; // end_CASE
        end;
        rec.reset();
    end;

    procedure CollectFreeNumberInRange(VAR r_PermissionRange: Record 2000000044);
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Int: Record Integer;
    begin
        Int.SETRANGE(Number, r_PermissionRange.From, r_PermissionRange."To");
        IF Int.FindSet() THEN
            REPEAT
                IF NOT AllObjWithCaption.GET(r_PermissionRange."Object Type", Int.Number) THEN
                    AddObjectToCollection(r_PermissionRange."Object Type", Int.Number);
            UNTIL Int.Next() = 0;
    end;

    procedure AddObjectToCollection(i_ObjectTypeIndex: Integer; i_ObjectID: Integer)
    BEGIN
        rec.init();
        rec."Object Type" := i_ObjectTypeIndex;
        rec."Object ID" := i_ObjectID;
        rec."Object Name" := FORMAT(rec."Object Type") + FORMAT(rec."Object ID");
        rec.Insert();
    END;

    procedure ApplyObjectTypeFilter(i_TypeIndex: Integer)
    begin
        Rec.FilterGroup(2);
        rec.SETRANGE("Object Type", i_TypeIndex);
        IF i_TypeIndex = 0 THEN
            rec.SETRANGE("Object Type");
        Rec.FilterGroup(2);
        CurrPage.UPDATE(FALSE);
        IF rec.FINDFIRST() THEN;
    end;




    var
        dgDialog: Dialog;
        iQtyCodeunits: Integer;
        iQtyReport: Integer;
        iQtyTable: Integer;
        iQtyXMLport: Integer;
        iQtyPages: Integer;
        iQtyQueries: Integer;
        iTotal: Integer;

}