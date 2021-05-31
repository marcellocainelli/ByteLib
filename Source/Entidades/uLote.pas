unit uLote;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TLote = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;

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
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TLote.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.AddParametro('CodFilial', '1', ftString);
  FEntidadeBase.AddParametro('CodProd', '-1', ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
end;

procedure TLote.ModificaDisplayCampos;
begin

end;

end.
