page 73011 DMTFreeObjectsInLicense
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
                                Rec.SetRange("Object Type", Rec."Object Type"::XMLport);
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
                Image = Filter;
                trigger OnAction()
                begin
                    LoadAppObj();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        Choice: Integer;
    begin
        Choice := StrMenu('Bereich 50000..99999,' +
                          'Bereich 50000..99999 & 110000..149999 (Solution Developer),' +
                          'Sind App Objekte in der Lizenz',
                          0, 'Was soll untersucht werden?');
        case Choice of
            1:
                begin
                    Clear(ObjInLicenseFilters);
                    GlobalObjectRangeFilter := '50000..99999';
                    GlobalAppFilter := '';
                end;
            2:
                begin
                    Clear(ObjInLicenseFilters);
                    GlobalObjectRangeFilter := '50000..99999|110000..149999';
                    GlobalAppFilter := '';
                end;
            3:
                begin
                    Clear(ObjInLicenseFilters);
                    GlobalObjectRangeFilter := '';
                    GlobalAppFilter := SelectAppFilter();
                end;
        end;
        LoadFreeObjInLicense();
        LoadAppObj();
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
        Rec.DeleteAll();
        Rec := AllObjWithCaption;

        Progress.Open('Gefundene Objekte #######1#');

        FindObjectRangesOfRIMDXObjects();

        foreach TypeNo in ObjInLicenseFilters.Keys do begin
            Int.SetFilter(Number, ObjInLicenseFilters.Get(TypeNo));
            if Int.FindSet() then
                repeat
                    if not AllObjWithCaption.Get(TypeNo, Int.Number) then
                        AddObjectToCollection(TypeNo, Int.Number);
                until Int.Next() = 0;
            if (CurrentDateTime - LastUpdate) > 500 then begin
                Progress.Update(1, Rec.Count);
                LastUpdate := CurrentDateTime;
            end;
        end;
        Progress.Close();
        CountObjectsFound();

        if Rec.FindFirst() then;
        IsLoaded := true;
    end;

    procedure LoadAppObj()
    var
        AllObjWithCaption: Record AllObjWithCaption;
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        AppPackageIDFilter: Text;
    begin
        if AppPackageIDFilter = '' then
            exit;
        AllObjWithCaption.SetRange("App Package ID", AppPackageIDFilter);
        AllObjWithCaption.FindSet();
        repeat
            TempAllObjWithCaption := AllObjWithCaption;
            if not IsObjectInLicense(TempAllObjWithCaption) then
                TempAllObjWithCaption."Object Subtype" := 'NotInLicense';
            TempAllObjWithCaption.Insert();
        until AllObjWithCaption.Next() = 0;
        Rec.Copy(TempAllObjWithCaption, true);
    end;

    procedure GetMaxObjectType(): Integer
    begin
        exit(10);
    end;

    procedure CountObjectsFound();
    var
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
        i: Integer;
    begin
        TempAllObjWithCaption.Copy(Rec, true);
        for i := 1 to GetMaxObjectType() do begin
            TempAllObjWithCaption."Object Type" := i;
            Rec.SetRange("Object Type", i);
            case TempAllObjWithCaption."Object Type" of
                TempAllObjWithCaption."Object Type"::Table:
                    NoOfTables := Rec.Count;
                TempAllObjWithCaption."Object Type"::Page:
                    NoOfPages := Rec.Count;
                TempAllObjWithCaption."Object Type"::Report:
                    NoOfReports := Rec.Count;
                TempAllObjWithCaption."Object Type"::Codeunit:
                    NoOfCodeunits := Rec.Count;
                TempAllObjWithCaption."Object Type"::Query:
                    NoOfQueries := Rec.Count;
                TempAllObjWithCaption."Object Type"::XMLport:
                    NoOfXMLports := Rec.Count;
                TempAllObjWithCaption."Object Type"::Enum:
                    NoOfEnums := Rec.Count;
            end; // end_CASE
        end;
        Rec.Reset();
    end;

    procedure AddObjectToCollection(ObjectTypeIndex: Integer; ObjectID: Integer)
    begin
        Rec.Init();
        Rec."Object Type" := ObjectTypeIndex;
        Rec."Object ID" := ObjectID;
        Rec."Object Name" := StrSubstNo('%1%2', Rec."Object Type", Rec."Object ID");
        Rec.Insert();
    end;

    procedure IsObjectInLicense(AllObjWithCpt: Record AllObjWithCaption) RIMDX: Boolean
    var
        LicPerm: Record "License Permission";
    begin
        LicPerm.Get(AllObjWithCpt."Object Type", AllObjWithCpt."Object ID");
        RIMDX := (LicPerm."Read Permission" = LicPerm."Read Permission"::Yes) and
                 (LicPerm."Insert Permission" = LicPerm."Insert Permission"::Yes) and
                 (LicPerm."Modify Permission" = LicPerm."Modify Permission"::Yes) and
                 (LicPerm."Delete Permission" = LicPerm."Delete Permission"::Yes) and
                 (LicPerm."Execute Permission" = LicPerm."Execute Permission"::Yes);
    end;

    local procedure FindObjectRangesOfRIMDXObjects()
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
        if GlobalObjectRangeFilter <> '' then begin
            PermRange.SetFilter(From, GlobalObjectRangeFilter);
            PermRange.SetFilter("To", GlobalObjectRangeFilter);
        end;
        PermRange.FindSet();
        repeat
            if not ObjInLicenseFilters.ContainsKey(PermRange."Object Type") then begin
                ObjInLicenseFilters.Add(PermRange."Object Type", StrSubstNo('%1..%2', PermRange.From, PermRange."To"))
            end else begin
                ObjInLicenseFilters.Set(PermRange."Object Type", ObjInLicenseFilters.Get(PermRange."Object Type") + StrSubstNo('|%1..%2', PermRange.From, PermRange."To"));
            end;
        until PermRange.Next() = 0;
    end;

    procedure SelectAppFilter() AppPackageIDFilter: Text
    var
        Apps: Record "NAV App Installed App";
        AppList: Dictionary of [Text, Guid];
        Choice: Integer;
        AppText: Text;
        Choices: Text;
    begin
        Apps.SetFilter(Publisher, '<>Microsoft');
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

        Apps.Get(AppList.Get(Choices.Split(',').Get(Choice)));
        AppPackageIDFilter := Format(Apps."Package ID");
    end;

    var
        [InDataSet]
        IsLoaded: Boolean;
        LastUpdate: DateTime;
        Progress: Dialog;
        ObjInLicenseFilters: Dictionary of [Integer, Text];
        NoOfCodeunits, NoOfEnums, NoOfPages, NoOfQueries, NoOfReports, NoOfTables, NoOfXMLports : Integer;
        RunMode: Option FreeIDs,AppIDs;
        GlobalAppFilter, GlobalObjectRangeFilter : Text;
}