unit uVasilhame_Entrada_itens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, StrUtils;
Type
  TVasilhameEntradaItens = class(TInterfacedObject, iEntidade)
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


{ TVasilhameEntradaItens }

constructor TVasilhameEntradaItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'Select vei.*, p.nome_prod ' +
    'From VASILHAME_ENTRADA_ITENS vei ' +
    'join produtos p on (p.cod_prod = vei.cod_prod)');
  InicializaDataSource;
  FEntidadeBase.InsertNewRecordEvent(OnNewRecord);
end;

destructor TVasilhameEntradaItens.Destroy;
begin
  inherited;
end;

class function TVasilhameEntradaItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TVasilhameEntradaItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TVasilhameEntradaItens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSQL;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSQL + ' Where ID_ENTRADA = :pParametro';
  end;
  FEntidadeBase.AddParametro('pParametro', FEntidadeBase.TextoPesquisa, ftString);
  //FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.SetReadOnly(Value, 'NOME_PROD', False);
end;

function TVasilhameEntradaItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('pParametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' Where ID_ENTRADA = :pParametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TVasilhameEntradaItens.ModificaDisplayCampos;
begin

end;

procedure TVasilhameEntradaItens.OnNewRecord(DataSet: TDataSet);
begin

end;

function TVasilhameEntradaItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
