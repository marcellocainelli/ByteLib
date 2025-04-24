unit uHaver;
interface
uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;
Type
  THaver = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure OnNewRecord(DataSet: TDataSet);
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;
{ THaver }
constructor THaver.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select h.* from haver h ' +
    'join caixa cx on (h.num_oper = cx.num_oper) ' +
    'where h.baixado = ''X'' and cx.cod_filial = :pCodFilial ');
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;
destructor THaver.Destroy;
begin
  inherited;
end;
class function THaver.New: iEntidade;
begin
  Result:= Self.Create;
end;
function THaver.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function THaver.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' and h.num_oper = :pParametro';
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' and h.cod_Cli = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NUM_OPER');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, ['Marcado'], [ftBoolean]);
  ModificaDisplayCampos;
  Value.DataSet.Open;
end;

function THaver.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NUM_OPER');
  FEntidadeBase.AddParametro('pCodFilial', '-1', ftString);
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' and h.num_oper = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;
procedure THaver.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
end;

function THaver.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;


procedure THaver.OnNewRecord(DataSet: TDataSet);
begin
end;
end.
