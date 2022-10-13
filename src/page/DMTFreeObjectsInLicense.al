page 110000 "DMTFreeObjectsInLicense"
{
    CaptionML = ENU = 'Free Objects in License', DEU = 'Freie Objekte in der Lizenz';
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTable = AllObjWithCaption;
    PageType = List;
    SourceTableTemporary = true;
    PromotedActionCategoriesML = ENU = 'Objects,Apps', DEU = 'Objekte,Apps';

    layout
    {
        area(Content)
        {
            group(ObjectTypes)
            {
                ShowCaption = false;
                grid(ObjectTypesGrid)
                {
                    GridLayout = Columns;
                    ShowCaption = false;
                    group(grid1)
                    {
                        ShowCaption = false;
                        field(Page; StrSubstNo('Page(%1)', NoOfPages))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Rec.SetRange("Object Type", Rec."Object Type"::Page);
                                CurrPage.Update();
                            end;
                        }
                    }
                    group(grid2)
                    {
                        ShowCaption = false;
                        field(Table; StrSubstNo('Table(%1)', NoOfTables))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Rec.SetRange("Object Type", Rec."Object Type"::Table);
                                CurrPage.Update();
                            end;
                        }
                    }
                    group(grid3)
                    {
                        ShowCaption = false;
                        field(Codeunit; StrSubstNo('Codeunit(%1)', NoOfCodeunits))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Rec.SetRange("Object Type", Rec."Object Type"::Codeunit);
                                CurrPage.Update();
                            end;
                        }
                    }
                    group(grid4)
                    {
                        ShowCaption = false;
                        field(Query; StrSubstNo('Query(%1)', NoOfQueries))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Rec.SetRange("Object Type", Rec."Object Type"::Query);
                                CurrPage.Update();
                            end;
                        }
                    }
                    group(grid5)
                    {
                        ShowCaption = false;
                        field(XMLPort; StrSubstNo('XMLPort(%1)', NoOfXMLports))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Rec.SetRange("Object Type", Rec."Object Type"::XMLPort);
                                CurrPage.Update();
                            end;
                        }
                    }
                    group(grid6)
                    {
                        ShowCaption = false;
                        field(Report; StrSubstNo('Report(%1)', NoOfReports))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Rec.SetRange("Object Type", Rec."Object Type"::Report);
                                CurrPage.Update();
                            end;
                        }
                    }
                    group(grid7)
                    {
                        ShowCaption = false;
                        field(Enum; StrSubstNo('Enum(%1)', NoOfEnums))
                        {
                            ApplicationArea = All;
                            ShowCaption = false;
                            trigger OnDrillDown()
                            begin
                                Rec.SetRange("Object Type", Rec."Object Type"::Enum);
                                CurrPage.Update();
                            end;
                        }
                    }
                }
            }

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
            action(AppFilter)
            {
                ApplicationArea = All;
                trigger OnAction()
                begin
                    LoadAppObj();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        ObjectRangeFilter := '50000..99999';
        LoadAppObj();
        // LoadFreeObjInLicense();
    end;

    procedure LoadFreeObjInLicense()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Int: Record Integer;
        TypeNo: Integer;
    begin
        if RunMode <> RunMode::FreeIDs then
            exit;
        if ObjInLicenseFilters.Count > 0 then
            exit;

        LastUpdate := CurrentDateTime;
        AllObjWithCaption := Rec;
        rec.DeleteAll();
        Rec := AllObjWithCaption;

        Progress.Open('Gefundene Objekte #######1#');

        FindObjectRange();

        foreach TypeNo in ObjInLicenseFilters.Keys do begin
            Int.SetFilter(Number, ObjInLicenseFilters.Get(TypeNo));
            if Int.FindSet() then
                repeat
                    IF not AllObjWithCaption.Get(TypeNo, Int.Number) THEN
                        AddObjectToCollection(TypeNo, Int.Number);
                until Int.Next() = 0;
            if (CurrentDateTime - LastUpdate) > 500 then begin
                Progress.Update(1, Rec.Count);
                LastUpdate := CurrentDateTime;
            end;
        end;
        Progress.Close();

        GetQtyObjetstByType();

        IF rec.FindFirst() THEN;
        IsLoaded := true;
    end;

    procedure LoadAppObj()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        AppPackageIDFilter: Text;
    begin
        // if RunMode <> RunMode::AppIDs then
        //     exit;
        begin
            AppPackageIDFilter := SelectAppFilter();
            AllObjWithCaption.SetRange("App Package ID", AppPackageIDFilter);
            AllObjWithCaption.FindSet();
            repeat
                TempAllObjWithCaption := AllObjWithCaption;
                TempAllObjWithCaption.Insert();
            until AllObjWithCaption.Next() = 0;
            Rec.Copy(TempAllObjWithCaption, true);
        end;
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
        for i := 1 to GetMaxObjectType() do begin
            permissionRange."Object Type" := i;
            rec.SetRange("Object Type", i);
            case permissionRange."Object Type" of
                permissionRange."Object Type"::Table:
                    NoOfTables := rec.Count;
                permissionRange."Object Type"::Page:
                    NoOfPages := rec.Count;
                permissionRange."Object Type"::Report:
                    NoOfReports := rec.Count;
                permissionRange."Object Type"::Codeunit:
                    NoOfCodeunits := rec.Count;
                permissionRange."Object Type"::Query:
                    NoOfQueries := rec.Count;
                permissionRange."Object Type"::XMLport:
                    NoOfXMLports := rec.Count;
                permissionRange."Object Type"::Enum:
                    NoOfEnums := rec.Count;
            end; // end_CASE
        end;
        rec.reset();
    end;

    procedure AddObjectToCollection(ObjectTypeIndex: Integer; ObjectID: Integer)
    begin
        rec.init();
        rec."Object Type" := ObjectTypeIndex;
        rec."Object ID" := ObjectID;
        rec."Object Name" := StrSubstNo('%1%2', rec."Object Type", rec."Object ID");
        rec.Insert();
    end;

    local procedure FindObjectRange()
    var
        PermRange: Record "Permission Range";
    begin
        if ObjInLicenseFilters.Count > 0 then
            exit;
        PermRange.Reset();
        PermRange.SetFilter("Object Type", 'Table|Report|Codeunit|XMLport|Page|Query|Enum');
        PermRange.SetRange("Read Permission", PermRange."Read Permission"::Yes);
        PermRange.SetRange("Insert Permission", PermRange."Insert Permission"::Yes);
        PermRange.SetRange("Modify Permission", PermRange."Modify Permission"::Yes);
        PermRange.SetRange("Delete Permission", PermRange."Delete Permission"::Yes);
        PermRange.SetRange("Execute Permission", PermRange."Execute Permission"::Yes);
        PermRange.FindSet();
        repeat
            if not ObjInLicenseFilters.ContainsKey(PermRange."Object Type") then begin
                ObjInLicenseFilters.Add(PermRange."Object Type", StrSubstNo('%1..%2', PermRange.From, PermRange."To"))
            end else begin
                ObjInLicenseFilters.Set(PermRange."Object Type", ObjInLicenseFilters.get(PermRange."Object Type") + StrSubstNo('|%1..%2', PermRange.From, PermRange."To"));
            end;
        until PermRange.Next() = 0;
    end;

    procedure SelectAppFilter() AppPackageIDFilter: Text
    var
        Apps: Record "NAV App Installed App";
        AppList: Dictionary of [Text, Guid];
        Choices: Text;
        Choice: Integer;
        AppText: Text;
    begin
        Apps.setfilter(Publisher, '<>Microsoft');
        Apps.FindSet();
        repeat
            AppText := StrSubstNo('%1_%2', Apps.Publisher, Apps.Name);
            if not AppList.Keys.Contains(AppText) then begin
                AppList.Add(AppText, Apps."App ID");
                Choices += ',' + AppText;
            end;
        until Apps.Next() = 0;
        Choices += ',Abbrechen';
        Choice := StrMenu(Choices, Choices.Split(',').Count);
        if Choice = Choices.Split(',').Count then
            exit;

        Apps.Get(AppList.Get(Choices.Split(',').get(Choice)));
        AppPackageIDFilter := format(Apps."Package ID");
    end;

    var
        Progress: Dialog;
        NoOfCodeunits, NoOfPages, NoOfQueries, NoOfReports, NoOfTables, NoOfXMLports, NoOfEnums : Integer;
        iTotal: Integer;
        [InDataSet]
        IsLoaded: Boolean;
        ObjectRangeFilter: Text;
        LastUpdate: DateTime;
        ObjInLicenseFilters: Dictionary of [Integer, Text];
        RunMode: Option FreeIDs,AppIDs;


}