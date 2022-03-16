unit uOrdStatus;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TOrdStatus = class(TInterfacedObject, iEntidade)
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

{ TOrdStatus }

constructor TOrdStatus.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORD_STATUS');
end;

destructor TOrdStatus.Destroy;
begin
  inherited;
end;

class function TOrdStatus.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdStatus.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdStatus.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('CODIGO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdStatus.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TOrdStatus.ModificaDisplayCampos;
begin

end;


end.
