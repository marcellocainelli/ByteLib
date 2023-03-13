unit uLote;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TLote = class(TInterfacedObject, iEntidade)
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

{ TLote }

constructor TLote.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select E.ID, E.LOTE, E.LOTE as CODIGO, E.COMPLEMENTO, E.VALIDADE, E.QUANTIDADE, 0 as INDICE From ESTOQUEFILIAL_LOTE E ' +
                         'Where E.COD_FILIAL = :CodFilial and E.COD_PROD = :CodProd ' +
                         'Order By 2');

  InicializaDataSource;
end;

destructor TLote.Destroy;
begin

  inherited;
end;

class function TLote.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TLote.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TLote.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TLote.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('CodFilial', '1', ftString);
  FEntidadeBase.AddParametro('CodProd', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
end;

procedure TLote.ModificaDisplayCampos;
begin

end;

function TLote.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
