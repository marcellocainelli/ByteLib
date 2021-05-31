unit uAcessoMenu;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TAcessoMenu = class(TInterfacedObject, iEntidade)
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

{ TAcessoMenu }

constructor TAcessoMenu.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select D.MENID_PKFK, D.DIRCONSULTAR, D.DIRNOVO, D.DIRALTERAR, D.DIRAPAGAR, M.MENNOME, M.MENACTION ' +
                         'From DIREITOSUSUARIO D ' +
                         'Join MENU M on (M.MENID_PK = D.MENID_PKFK) ' +
                         'Where D.USUID_PKFK = :CODUSUARIO ' +
                         'Order By M.MENNOME');
end;

destructor TAcessoMenu.Destroy;
begin
  inherited;
end;

class function TAcessoMenu.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TAcessoMenu.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TAcessoMenu.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('MENID_PKFK');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TAcessoMenu.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.AddParametro('CODUSUARIO', -1, ftInteger);
  FEntidadeBase.Iquery.IndexFieldNames('MENID_PKFK');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);

  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TAcessoMenu.ModificaDisplayCampos;
begin

end;

end.
