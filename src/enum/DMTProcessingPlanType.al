enum 110009 "DMTProcessingPlanType"
{
    Extensible = true;

    value(0; " ") { }
    value(1; "Group") { Caption = 'Group'; }
    value(2; "Run Codeunit") { Caption = 'Run Codeunit'; }
    value(3; "Import To Buffer") { Caption = 'Import to Buffer'; }
    value(4; "Import To Target") { Caption = 'Import to Target'; }
    value(5; "Update Field") { Caption = 'Update Field'; }
    value(6; "Buffer + Target") { Caption = 'Buffer + Target'; }
}