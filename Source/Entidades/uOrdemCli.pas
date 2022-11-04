unit uOrdemCli;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;
Type
  TOrdemCli = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
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

{ TOrdemEquipamento }

constructor TOrdemCli.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORD_CLI');

  InicializaDataSource;
end;

destructor TOrdemCli.Destroy;
begin
  inherited;
end;

class function TOrdemCli.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdemCli.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdemCli.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  vTextoSQL:= FEntidadeBase.TextoSql + ' where COD_FILIAL = :pCod_Filial ';
  Case FEntidadeBase.TipoPesquisa of
    1: vTextoSQL:= vTextoSQL + ' and CAIXA_NUM_OPER = :Parametro';
    2: vTextoSQL:= vTextoSQL + ' and COD_FUN = :Parametro';
    3: vTextoSQL:= vTextoSQL + ' and COD_CLI = :Parametro';
    4: vTextoSQL:= vTextoSQL + ' and DT_SINCRONISMO is :Parametro';
    5: vTextoSQL:= vTextoSQL + ' and COD_FUN = :Parametro and DT_ORDEM between :pDtInicio and :pDtFim';
    6: vTextoSQL:= vTextoSQL + ' and NR_ORDEM = :Parametro';
  end;

  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NR_ORDEM');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdemCli.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;

  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL + ' where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrdemCli.ModificaDisplayCampos;
begin

end;

function TOrdemCli.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
