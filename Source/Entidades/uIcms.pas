unit uIcms;

interface

uses
  Model.Entidade.Interfaces, Data.DB;

Type
  TIcms = class(TInterfacedObject, iEntidade)
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

{ TCst }

constructor TIcms.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from ICMS where COD_FILIAL = :pCod_Filial');
end;

destructor TIcms.Destroy;
begin
  inherited;
end;

class function TIcms.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TIcms.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TIcms.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('COD_ICMS');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TIcms.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TIcms.ModificaDisplayCampos;
begin

end;

end.
