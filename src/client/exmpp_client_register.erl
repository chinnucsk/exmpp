%% $Id$

%% @author Mickael Remond <mickael.remond@process-one.net>

%% @doc

%% The module <strong>{@module}</strong> implements packets formatting
%% conforming to XEP-0077: In-Band Registration.
%% See: http://www.xmpp.org/extensions/xep-0077.html
%%
%% <p>This code is copyright Process-one (http://www.process-one.net/)</p>
%%
%% Note: This implementation is still partial and does not support all
%% workflow of the XEP-0077.

-module(exmpp_client_register).

-include("exmpp.hrl").

-export([get_registration_fields/0,
	 get_registration_fields/1,
	 register_account/1, register_account/2]).

%% @spec () -> Register_Iq
%%     Register_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to get the instruction to register and the list
%% of registration fields.
%%
%% The stanza `id' is generated automatically.

get_registration_fields() ->
    get_registration_fields(register_id()).

%% @spec (Id) -> Register_Iq
%%     Id = string()
%%     Register_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' to get the instruction to register and the list
%% of registration fields.

get_registration_fields(Id) ->
    Id = register_id(),
    %% Make empty query
    Query = #xmlnselement{ns = ?NS_JABBER_REGISTER, name = 'query'},
    Iq = exmpp_xml:set_attributes(
	   #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq'},
	   [{'type', "get"}, {'id', Id}]),
    exmpp_xml:append_child(Iq, Query).

%% @spec (Fields) -> Register_Iq
%%     Fields = [Field]
%%     Field = {Fieldname, Value}
%%     Fieldname = atom()
%%     Value = string()
%%     Register_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' that prepare a registration packet for the user.
register_account(Fields) ->
    register_account(register_id(), Fields).

%% @spec (Id, Fields) -> Register_Iq
%%     Id = string()
%%     Fields = [Field]
%%     Field = {Fieldname, Value}
%%     Fieldname = atom()
%%     Value = string()
%%     Register_Iq = exmpp_xml:xmlnselement()
%% @doc Make an `<iq>' that prepare a registration packet for the user.
register_account(Id, Fields) ->
    %% Make query tag
    Query =  #xmlnselement{ns = ?NS_JABBER_REGISTER, name = 'query'},
    %% Add fields to the query tag
    PreparedQuery = append_fields(Query, Fields),
    %% Put the prepared query in IQ
    Iq = exmpp_xml:set_attributes(
	   #xmlnselement{ns = ?NS_JABBER_CLIENT, name = 'iq'},
	   [{'type', "set"}, {'id', Id}]),
    exmpp_xml:append_child(Iq, PreparedQuery).

%% @hidden
%% @doc Append each register request field to the query and return the
%% prepared query
append_fields(PreparedQuery, []) ->
    PreparedQuery;
append_fields(Query, [{Field, Value}|Fields])
  when atom(Field),
       list(Value) -> 
    FieldElement = exmpp_xml:set_cdata(
		     #xmlnselement{ns = ?NS_JABBER_REGISTER, name = Field},
		     Value),
    UpdatedQuery = exmpp_xml:append_child(Query, FieldElement),
    append_fields(UpdatedQuery, Fields).

%% TODO: register_form



%% @spec () -> Register_ID
%%     Register_ID = string()
%% @doc Generate a random register iq ID.
%%
%% This function uses {@link random:uniform/1}. It's up to the caller to
%% seed the generator.

register_id() ->
	"reg-" ++ integer_to_list(random:uniform(65536 * 65536)).
