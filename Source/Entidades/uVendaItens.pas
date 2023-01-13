unit uVendaItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils, StrUtils;
Type
  TVendaItens = class(TInterfacedObject, iEntidade)
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

{ TVendaItens }

constructor TVendaItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  InicializaDataSource;
end;

destructor TVendaItens.Destroy;
begin
  inherited;
end;

class function TVendaItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TVendaItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TVendaItens.Consulta(Value: TDataSource): iEntidade;
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
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NUM_OPER');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;

  FEntidadeBase.SetReadOnly(Value, 'PESO', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_LOTE', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_GRADE', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_SERIAL', False);
  FEntidadeBase.SetReadOnly(Value, 'FLG_MLFULL', False);
end;

function TVendaItens.InicializaDataSource(Value: TDataSource): iEntidade;
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

procedure TVendaItens.ModificaDisplayCampos;
begin

end;

function TVendaItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TVendaItens.SelecionaSQLConsulta;
begin
  FEntidadeBase.TextoSQL(
    'Select V.*, P.PESO, P.FLG_LOTE, P.FLG_GRADE, P.SERIAL as FLG_SERIAL, P.FLG_MLFULL ' +
    'From VENDA V ' +
    'Inner Join PRODUTOS P On (P.COD_PROD = V.COD_PROD) ');
end;

end.
