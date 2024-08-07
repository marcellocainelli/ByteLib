unit uVendaMedUsoContinuo;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;
Type
  TVendaMedUsoContinuo = class(TInterfacedObject, iEntidade)
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

{ TVendaMedUsoContinuo }

constructor TVendaMedUsoContinuo.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL(
    'select vuc.* from venda_med_usocontinuo vuc ' +
    'where (vuc.cod_cliente = :pCod_Cli) and (vuc.cod_produto = :pCod_Prod) ');
  InicializaDataSource;
end;

destructor TVendaMedUsoContinuo.Destroy;
begin
  inherited;
end;

class function TVendaMedUsoContinuo.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TVendaMedUsoContinuo.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TVendaMedUsoContinuo.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('COD_CLIENTE');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TVendaMedUsoContinuo.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('select vuc.* from venda_med_usocontinuo vuc where (1 <> 1 )');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TVendaMedUsoContinuo.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('DATA_PROXIMA_COMPRA')).EditMask:= '!99/99/00;1;_';
end;

function TVendaMedUsoContinuo.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
