unit uCaixa;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils, StrUtils;
Type
  TCaixa = class(TInterfacedObject, iEntidade)
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
      procedure SelecionaSQLConsulta;
  end;
implementation
uses
  uEntidadeBase;

{ TCaixa }

constructor TCaixa.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
end;

destructor TCaixa.Destroy;
begin
  inherited;
end;

class function TCaixa.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TCaixa.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TCaixa.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' Where NUM_OPER = :pParametro';
  end;
  If not FEntidadeBase.Inativos then
    vTextoSQL:= vTextoSQL + ' and SITUACAO = ''A'' ';
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NUM_OPER');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TCaixa.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  SelecionaSQLConsulta;
  FEntidadeBase.Iquery.IndexFieldNames('NUM_OPER');
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where NUM_OPER = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TCaixa.ModificaDisplayCampos;
begin

end;

function TCaixa.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TCaixa.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL('Select * From CAIXA ');
end;

end.
