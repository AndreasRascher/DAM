enum 110006 "DMTFieldValidationType"
{
    value(0; AlwaysValidate) { Caption = 'Always', Comment = 'Immer'; }
    value(1; ValidateOnlyIfNotEmpty) { Caption = 'If not empty', Comment = 'Wenn nicht leer'; }
    value(2; AssignWithoutValidate) { Caption = 'Assign without validation', Comment = 'Zuweisen ohne Validierung'; }
}