PGDMP     ,    3                 y            turkey    11.2    13.1 �   �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    232030    turkey    DATABASE     c   CREATE DATABASE turkey WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Russian_Russia.1251';
    DROP DATABASE turkey;
                postgres    false            	            2615    232695    admin    SCHEMA        CREATE SCHEMA admin;
    DROP SCHEMA admin;
                postgres    false                        3079    232860    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false            �           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    2            U           1255    232928 #   add_department(integer, text, json)    FUNCTION     B  CREATE FUNCTION admin.add_department(idep_dep_index integer, idep_name text, idep_properties json, OUT dep_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	dep_index = -1;
	if nullif(idep_name, '') is null then err_msg = 'Empty department name'; return; end if;
	insert into admin.departments as d (dep_dep_index, dep_name, dep_properties) 
	values(idep_dep_index, idep_name, idep_properties)
	returning d.dep_index into dep_index;
	return;
exception	
	when foreign_key_violation then err_msg = 'Invalid parent department'; return;
end;
$$;
 �   DROP FUNCTION admin.add_department(idep_dep_index integer, idep_name text, idep_properties json, OUT dep_index integer, OUT err_msg text);
       admin          postgres    false    9            X           1255    232935    add_funcblock(text, text)    FUNCTION     �  CREATE FUNCTION admin.add_funcblock(ifb_name text, ifb_fullname text, OUT fb_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	fb_index = -1;
	if nullif(ifb_name, '') is null then err_msg = 'Empty block name'; return; end if;	
	
	insert into admin.funcblocks as r (fb_name, fb_fullname)
	values(ifb_name, ifb_fullname)
	returning r.fb_index into fb_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Block full name is already exists'; return; 

end;
$$;
 m   DROP FUNCTION admin.add_funcblock(ifb_name text, ifb_fullname text, OUT fb_index integer, OUT err_msg text);
       admin          postgres    false    9            \           1255    232941 '   add_funcblockresource(integer, integer)    FUNCTION     �  CREATE FUNCTION admin.add_funcblockresource(ifb_index integer, ires_index integer, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
    insert into admin.funcblockresources(fb_index, res_index)
	values(ifb_index, ires_index);
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'FBRES_F_FKEY' then 
				err_msg = 'Invalid block'; 
			else
				err_msg = 'Invalid resource';
			end if;
			return;
		end;
	when unique_violation then err_msg = 'Resource is already assigned to block'	;						

end;
$$;
 d   DROP FUNCTION admin.add_funcblockresource(ifb_index integer, ires_index integer, OUT err_msg text);
       admin          postgres    false    9            Z           1255    232940 #   add_funcblockrole(integer, integer)    FUNCTION     �  CREATE FUNCTION admin.add_funcblockrole(ifb_index integer, irole_index integer, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
    insert into admin.funcblockroles(fb_index, role_index)
	values(ifb_index, irole_index);
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'FBROLE_F_FKEY' then 
				err_msg = 'Invalid block'; 
			else
				err_msg = 'Invalid role';
			end if;
			return;
		end;
	when unique_violation then err_msg = 'Block is already assigned to role'	;						

end;
$$;
 a   DROP FUNCTION admin.add_funcblockrole(ifb_index integer, irole_index integer, OUT err_msg text);
       admin          postgres    false    9            V           1255    232929 *   add_resource(integer, text, text, integer)    FUNCTION     o  CREATE FUNCTION admin.add_resource(ires_res_index integer, ires_name text, ires_fullname text, irtp_index integer, OUT res_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
	res_index = -1;
	if nullif(ires_name, '') is null then err_msg = 'Empty resource name'; return; end if;
	--Checking resource type
	if irtp_index is not null and not exists 
		(select * from admin.resourcetypes where is_visible and rtp_index =irtp_index  ) then
			err_msg = 'Invalid resource type';
			return;
	end if;	
	
	insert into admin.resources as r(res_res_index, res_name, res_fullname, rtp_index) 
	values(ires_res_index, ires_name, ires_fullname, irtp_index)
	returning r.res_index into res_index;
	return;
exception	
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'RES_RR_FKEY' then 
				err_msg = 'Invalid parent resource'; 
			else
				err_msg = 'Invalid resource type';
			end if;
			return;
		end;
	when unique_violation then err_msg ='Full name is already exists'	; return;	
end;
$$;
 �   DROP FUNCTION admin.add_resource(ires_res_index integer, ires_name text, ires_fullname text, irtp_index integer, OUT res_index integer, OUT err_msg text);
       admin          postgres    false    9            Y           1255    232931    add_resourcetype(text, text)    FUNCTION       CREATE FUNCTION admin.add_resourcetype(irtp_name text, irtp_fullname text, OUT rtp_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	rtp_index = -1;
	if nullif(irtp_name, '') is null then err_msg = 'Empty type name'; return; end if;	
	--check reserved names by system:
	if exists (select 1 from admin.resourcetypes
			   where trim(upper(rtp_name))=trim(upper(irtp_name)) and not is_visible) then
	err_msg = 'Type name is reserved by system';
	return;
	end if;
	
	insert into admin.resourcetypes as r (rtp_name, rtp_fullname, is_visible)
	values(irtp_name, irtp_fullname, true)
	returning r.rtp_index into rtp_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Type full name is already exists'; return; 

end;
$$;
 s   DROP FUNCTION admin.add_resourcetype(irtp_name text, irtp_fullname text, OUT rtp_index integer, OUT err_msg text);
       admin          postgres    false    9            W           1255    232930    add_role(text, text)    FUNCTION       CREATE FUNCTION admin.add_role(irole_name text, irole_fullname text, OUT role_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	role_index = -1;
	if nullif(irole_name, '') is null then err_msg = 'Empty role name'; return; end if;	
	
	insert into admin.roles as r (role_name, role_fullname)
	values(irole_name, irole_fullname)
	returning r.role_index into role_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Role full name is already exists'; return; 

end;
$$;
 n   DROP FUNCTION admin.add_role(irole_name text, irole_fullname text, OUT role_index integer, OUT err_msg text);
       admin          postgres    false    9            R           1255    232909 #   add_user(text, text, integer, json)    FUNCTION     �  CREATE FUNCTION admin.add_user(ilogin text, ipassword text, idep_index integer, iproperties json, OUT user_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	user_index = -1;
	if nullif(ilogin, '') is null then err_msg = 'Empty login'; return; end if;
	if nullif(ipassword, '') is null then err_msg = 'Empty password'; return; end if;	
	
	insert into admin.users as u (dep_index, user_login, user_password, user_properties)
	values(idep_index, ilogin, crypt(ipassword, gen_salt('md5')), iproperties)
	returning u.user_index into user_index;
	return;
	
	exception
		when unique_violation then err_msg = 'Login is already existed'; return; 

end;
$$;
 �   DROP FUNCTION admin.add_user(ilogin text, ipassword text, idep_index integer, iproperties json, OUT user_index integer, OUT err_msg text);
       admin          postgres    false    9            [           1255    232938    add_userrole(integer, integer)    FUNCTION     �  CREATE FUNCTION admin.add_userrole(iuser_index integer, irole_index integer, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
    insert into admin.userroles(user_index, role_index)
	values(iuser_index, irole_index);
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'USERROLE_U_FKEY' then 
				err_msg = 'Invalid user'; 
			else
				err_msg = 'Invalid role';
			end if;
			return;
		end;
	when unique_violation then err_msg = 'Role is already assigned to user'	;						

end;
$$;
 ^   DROP FUNCTION admin.add_userrole(iuser_index integer, irole_index integer, OUT err_msg text);
       admin          postgres    false    9            m           1255    232999    add_userrole_json(json)    FUNCTION     b  CREATE FUNCTION admin.add_userrole_json(ijson json) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
insrows integer;
delrows integer;
datarows integer;
begin
select count (*) into datarows from json_array_elements_text(ijson->'role_list');
if datarows!=0 then													
	with NewData as ( select (ijson->>'user_index')::integer user_index, r::integer role_index
				  from json_array_elements_text(ijson->'role_list') r),
	ins as (insert into admin.userroles as u (user_index, role_index)
		   select user_index, role_index from NewData
		   on conflict (user_index, role_index) do nothing
		   returning u.role_index as insrows),
	del as (delete from admin.userroles u  using NewData n 
			where u.user_index = n.user_index and u.role_index 
			not in (select role_index from NewData)
		   returning u.role_index as delrows) ,
	insr as (select count(*) cins  from ins),
	delr as (select count(*) cdel  from del)
	select cins, cdel into insrows, delrows from insr, delr;	
	raise info'%, %', insrows, delrows;	
else
	delete from admin.userroles where user_index = (ijson->>'user_index')::integer;
end if;

end;
$$;
 3   DROP FUNCTION admin.add_userrole_json(ijson json);
       admin          postgres    false    9            `           1255    232951 ,   change_password_by_user(integer, text, text)    FUNCTION     �  CREATE FUNCTION admin.change_password_by_user(iuser_index integer, old_password text, new_password text, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
	if  not(coalesce(admin.check_password(iuser_index, old_password), false)) then
		err_msg = 'Uncorrect password';
		return;
	else
		update admin.users set user_password = crypt(new_password, gen_salt('md5')) where user_index = iuser_index;
		return;
	end if;
end;
$$;
 z   DROP FUNCTION admin.change_password_by_user(iuser_index integer, old_password text, new_password text, OUT err_msg text);
       admin          postgres    false    9            o           1255    233625 "   change_password_by_user_json(json)    FUNCTION     �   CREATE FUNCTION admin.change_password_by_user_json(ijson json) RETURNS text
    LANGUAGE plpgsql
    AS $$
begin
	return admin.change_password_by_user((ijson->>'user_index')::integer, 
										 ijson->>'old_password', ijson->>'new_password');
end;
$$;
 >   DROP FUNCTION admin.change_password_by_user_json(ijson json);
       admin          postgres    false    9            p           1255    233626 "   change_user_properties(json, text)    FUNCTION     n  CREATE FUNCTION admin.change_user_properties(properties json, external_user text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
idep_index integer;
iproperties json;
begin
	idep_index = (properties->>'dep_index')::integer;
	--if idep_index not in (select dep_index from admin.users where user_index = iuser_index ) then
	update admin.users set dep_index = idep_index where user_index = (properties->>'user_index')::integer;
	--Здесь код на логгирование изменений
	--end if;
	iproperties = properties->'user_properties';
	--if iproperties::text not in (select user_properties::text from admin.users where user_index = iuser_index) then
	--Здесь код на логгирование изменений

	update admin.users set user_properties = iproperties where user_index = (properties->>'user_index')::integer;
	--end if;
		
end;
$$;
 Q   DROP FUNCTION admin.change_user_properties(properties json, external_user text);
       admin          postgres    false    9            r           1255    233629 +   change_user_properties(integer, json, text)    FUNCTION        CREATE FUNCTION admin.change_user_properties(iuser_index integer, properties json, external_user text, OUT err_msg text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
idep_index integer;
iproperties json;
num integer;
begin
	idep_index = (properties->>'dep_index')::integer;
	--if idep_index not in (select dep_index from admin.users where user_index = iuser_index ) then
	--update admin.users set dep_index = idep_index where user_index = iuser_index;
	--Здесь код на логгирование изменений
	--end if;
	iproperties = properties->'user_properties';
	--if iproperties::text not in (select user_properties::text from admin.users where user_index = iuser_index) then
	--Здесь код на логгирование изменений
	with x as (
	update admin.users set dep_index = idep_index, user_properties = iproperties where user_index = iuser_index
	returning *) select count(*) into num from x;
	if num=0 then
		err_msg='User not found';
	end if;
	--end if;
	return ;	
end;
$$;
 x   DROP FUNCTION admin.change_user_properties(iuser_index integer, properties json, external_user text, OUT err_msg text);
       admin          postgres    false    9            Q           1255    232912    check_password(integer, text)    FUNCTION     5  CREATE FUNCTION admin.check_password(iuser_index integer, ipassword text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
--password check
declare res boolean;
begin
	select u.user_password = crypt(ipassword, u.user_password) into res
	from admin.users u
	where user_index = iuser_index;
	return res;
end;
$$;
 I   DROP FUNCTION admin.check_password(iuser_index integer, ipassword text);
       admin          postgres    false    9            T           1255    232913    check_password(text, text)    FUNCTION     7  CREATE FUNCTION admin.check_password(ilogin text, ipassword text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
--проверка пароля
declare res boolean;
begin
	select u.user_password = crypt(ipassword, u.user_password) into res
	from admin.users u
	where user_login = ilogin;
	return res;
end;
$$;
 A   DROP FUNCTION admin.check_password(ilogin text, ipassword text);
       admin          postgres    false    9                       1255    233425    close_session(integer)    FUNCTION     �   CREATE FUNCTION admin.close_session(iuss_index integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update admin.usersessions set date_end = localtimestamp where uss_index = iuss_index;
end;
$$;
 7   DROP FUNCTION admin.close_session(iuss_index integer);
       admin          postgres    false    9            _           1255    232947 &   create_session(integer, integer, inet)    FUNCTION     �  CREATE FUNCTION admin.create_session(iuser_index integer, irole_index integer, iurl inet, OUT uss_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare 
err_key text;
begin
	uss_index = -1;
    insert into admin.usersessions as s(user_index, role_index, date_beg, uss_url)
	values(iuser_index, irole_index, localtimestamp, iurl)
	returning s.uss_index into uss_index;
	return;
							
exception
	when foreign_key_violation then 
		begin 
		  GET STACKED DIAGNOSTICS err_key =CONSTRAINT_NAME; 
		  Raise info '%', err_key;
			if upper(err_key) = 'USS_U_FKEY' then 
				err_msg = 'Invalid user'; 
			else
				err_msg = 'Invalid role';
			end if;
			return;
		end;					

end;
$$;
 �   DROP FUNCTION admin.create_session(iuser_index integer, irole_index integer, iurl inet, OUT uss_index integer, OUT err_msg text);
       admin          postgres    false    9            n           1255    233004    deleteusers(integer[])    FUNCTION     �  CREATE FUNCTION admin.deleteusers(del_indexes integer[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare delrows integer;
begin
	delete from admin.userroles where coalesce(array_position(del_indexes, user_index),0)>0;
	with x as (delete from admin.users where coalesce(array_position(del_indexes, user_index),0)>0
			    returning user_index)
	select count(*) into delrows from x;
	return delrows;	
end;
$$;
 8   DROP FUNCTION admin.deleteusers(del_indexes integer[]);
       admin          postgres    false    9            j           1255    232994    get_all_roles_list()    FUNCTION     (  CREATE FUNCTION admin.get_all_roles_list() RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
select json_agg(json_build_object('role_index', role_index,
								  'role_name', role_name, 'role_fullname', role_fullname))
								  into res
from admin.roles;
return res;
end;
$$;
 *   DROP FUNCTION admin.get_all_roles_list();
       admin          postgres    false    9            q           1255    233420    get_basic_resources(integer)    FUNCTION     s  CREATE FUNCTION admin.get_basic_resources(irole_index integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare res refcursor;
begin
open res for
with recursive x as (
	select r.res_index, r.res_name 
	from admin.resources r, admin.funcblockresources b, admin.funcblockroles f, admin.resourcetypes t
	where r.res_index=b.res_index and b.fb_index = f.fb_index and f.role_index =irole_index
	and r.res_res_index is null and r.rtp_index = t.rtp_index and t.is_visible = false
	union
		select r.res_index, r.res_name 
	from admin.resources r, x, admin.funcblockresources b, admin.funcblockroles f, admin.resourcetypes t
	where r.res_index=b.res_index and b.fb_index = f.fb_index and f.role_index =irole_index
	and r.res_res_index =x.res_index and r.rtp_index = t.rtp_index and t.is_visible = false
	and t.rtp_name='MainMenuComp')
	select res_name from x;
	
	return res;
end;
$$;
 >   DROP FUNCTION admin.get_basic_resources(irole_index integer);
       admin          postgres    false    9            f           1255    232985    get_department_tree(integer)    FUNCTION     �  CREATE FUNCTION admin.get_department_tree(idep_index integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare res refcursor;
begin
open res for 
	select dep_index, dep_name from(
	select dep_index, dep_name, rn from admin.dep_tree
	union  
	select -1 as dep_index, '------No departiment----' as dep_name, 0 as rn) a
	order by dep_index = idep_index desc, rn;
return res;
end;
$$;
 =   DROP FUNCTION admin.get_department_tree(idep_index integer);
       admin          postgres    false    9            h           1255    232991 !   get_department_tree_json(integer)    FUNCTION     �  CREATE FUNCTION admin.get_department_tree_json(idep_index integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
	select json_agg(json_build_object('dep_index', dep_index, 'dep_name', dep_name)) 
	into res from(select *from (
	select dep_index, dep_name, rn from admin.dep_tree
	union  
	select -1 as dep_index, '------No departiment----' as dep_name, 0 as rn ) b
	order by dep_index = idep_index desc, rn) a;	
return res;
end;
$$;
 B   DROP FUNCTION admin.get_department_tree_json(idep_index integer);
       admin          postgres    false    9            g           1255    232976     get_json_fulldata(text, integer)    FUNCTION     �  CREATE FUNCTION admin.get_json_fulldata(iuser_login text, irole_index integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
select json_build_object('User',json_build_object('user_index', u.user_index, 'user_login', user_login,
						  'dep_index', u.dep_index, 'dep_name', dep_name, 'user_properties', user_properties) ,
						 'Role', json_build_object('role_index', r.role_index, 
						'role_name', role_name, 'role_fullname', role_fullname)) into res
from admin.users u inner join admin.roles r on user_login = iuser_login and r.role_index = irole_index 
inner join  admin.userroles x on r.role_index = x.role_index and u.user_index = x.user_index
left join admin.departments d on u.dep_index = d.dep_index;
return res;
end;
$$;
 N   DROP FUNCTION admin.get_json_fulldata(iuser_login text, irole_index integer);
       admin          postgres    false    9            e           1255    232961 "   get_resource_access(integer, text)    FUNCTION     �  CREATE FUNCTION admin.get_resource_access(irole_index integer, ires_name text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
if exists(
select s.res_name
	from admin.resources s,  admin.funcblockresources b, admin.funcblockroles f where
	s.res_index = b.res_index and f.fb_index= b.fb_index and f.role_index =irole_index and
	trim(upper(s.res_name))=trim(upper(ires_name))) then return true;
	else return false;
	end if;
end;
$$;
 N   DROP FUNCTION admin.get_resource_access(irole_index integer, ires_name text);
       admin          postgres    false    9            S           1255    232972 ,   get_resource_access_childlist(integer, text)    FUNCTION       CREATE FUNCTION admin.get_resource_access_childlist(irole_index integer, ires_name text) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare res refcursor;
begin
open res for 
with recursive r as (
select s.res_index, s.res_name 
	from admin.resources s, admin.resources u,  admin.funcblockresources b, admin.funcblockroles f where
	s.res_index = b.res_index and f.fb_index= b.fb_index and f.role_index =irole_index and
	trim(upper(u.res_name))=trim(upper(ires_name)) and s.res_res_index = u.res_index
union
	select s.res_index, s.res_name
	from 	admin.resources s, r,  admin.funcblockresources b, admin.funcblockroles f where
	s.res_index = b.res_index and f.fb_index= b.fb_index and f.role_index = irole_index and
	s.res_res_index = r.res_index
)
select res_name from r;
return res;
end;
$$;
 X   DROP FUNCTION admin.get_resource_access_childlist(irole_index integer, ires_name text);
       admin          postgres    false    9            c           1255    232956    get_user_index(text)    FUNCTION     �   CREATE FUNCTION admin.get_user_index(iuser_login text) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
declare iuser_index integer;
begin
select user_index into iuser_index from admin.users where user_login = $1;
return iuser_index;
end;
$_$;
 6   DROP FUNCTION admin.get_user_index(iuser_login text);
       admin          postgres    false    9            i           1255    232992    get_userlist_json()    FUNCTION     �  CREATE FUNCTION admin.get_userlist_json() RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
	select json_agg(json_build_object('user_index', user_index, 'user_login', user_login, 
							'dep_index', dep_index, 'user_properties', user_properties::json)) 
	into res from(select * from(
	select user_index, user_login, dep_index, user_properties::text from admin.users
	union  
	select -1 as user_index, '------No user selected----' , -1,  '{}') b order by user_index
) a;	
return res;
end;
$$;
 )   DROP FUNCTION admin.get_userlist_json();
       admin          postgres    false    9            b           1255    232953    get_userrolelist(integer)    FUNCTION     �  CREATE FUNCTION admin.get_userrolelist(iuser_index integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
 declare res json;
begin
	select json_agg(json_build_object('role_index', r.role_index, 'role_name', r.role_name, 'role_fullname', r.role_fullname ))
	into res
	from admin.roles r, admin.userroles u 
	where u.user_index = iuser_index and u.role_index = r.role_index;	
	return res;
end;
$$;
 ;   DROP FUNCTION admin.get_userrolelist(iuser_index integer);
       admin          postgres    false    9            a           1255    232954    get_userrolelist(text)    FUNCTION     �  CREATE FUNCTION admin.get_userrolelist(iuser_login text) RETURNS json
    LANGUAGE plpgsql
    AS $$
 declare res json;
begin
	select json_agg(json_build_object('role_index', r.role_index, 'role_name', r.role_name, 'role_fullname', r.role_fullname ))
	into res
	from admin.roles r, admin.userroles u , admin.users a
	where a.user_login = iuser_login and u.role_index = r.role_index and a.user_index = u.user_index;	
	return res;
end;
$$;
 8   DROP FUNCTION admin.get_userrolelist(iuser_login text);
       admin          postgres    false    9            s           1255    233631    get_userrolenolist(text)    FUNCTION     �  CREATE FUNCTION admin.get_userrolenolist(iuser_login text) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
	select json_agg(json_build_object('role_index', r.role_index, 'role_name', r.role_name, 'role_fullname', r.role_fullname ))
	into res
	from admin.roles r
	where r.role_index not in (select u.role_index from admin.userroles u, admin.users a 
							   where  a.user_login = iuser_login and a.user_index = u.user_index  ) ;	
	return res;
end;
$$;
 :   DROP FUNCTION admin.get_userrolenolist(iuser_login text);
       admin          postgres    false    9            k           1255    232997    register_user(json)    FUNCTION     �  CREATE FUNCTION admin.register_user(ijson json, OUT user_index integer, OUT err_msg text) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare
newuserinfo record;
begin
user_index = -1;
newuserinfo =admin.add_user(ijson->>'user_login', ijson->>'user_password',(ijson->>'dep_index')::integer,
						   ijson->'user_properties');
					
if coalesce(newuserinfo.err_msg	,'')!='' then err_msg =newuserinfo.err_msg;  return; end if; 				 
					 
select string_agg(admin.add_userrole(newuserinfo.user_index, r::integer), ' ') into err_msg
from  json_array_elements_text(ijson->'role_list') r;

user_index=newuserinfo.user_index;
return;
end;
$$;
 Y   DROP FUNCTION admin.register_user(ijson json, OUT user_index integer, OUT err_msg text);
       admin          postgres    false    9            l           1255    233000    upd_userrole_json(json)    FUNCTION     �  CREATE FUNCTION admin.upd_userrole_json(ijson json, OUT insrows integer, OUT delrows integer) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare 
datarows integer;
begin
select count (*) into datarows from json_array_elements_text(ijson->'role_list');
if datarows!=0 then													
	with NewData as ( select (ijson->>'user_index')::integer user_index, r::integer role_index
				  from json_array_elements_text(ijson->'role_list') r),
	ins as (insert into admin.userroles as u (user_index, role_index)
		   select user_index, role_index from NewData
		   on conflict (user_index, role_index) do nothing
		   returning u.role_index as insrows),
	del as (delete from admin.userroles u  using NewData n 
			where u.user_index = n.user_index and u.role_index 
			not in (select role_index from NewData)
		   returning u.role_index as delrows) ,
	insr as (select count(*) cins  from ins),
	delr as (select count(*) cdel  from del)
	select cins, cdel into insrows, delrows from insr, delr;	
else
with del as (
	delete from admin.userroles where user_index = (ijson->>'user_index')::integer
	returning role_index as delrows)
	select count(*) into delrows from del;
	insrows = 0;
end if;
end;
$$;
 ]   DROP FUNCTION admin.upd_userrole_json(ijson json, OUT insrows integer, OUT delrows integer);
       admin          postgres    false    9            O           1255    232910    check_password(integer, text)    FUNCTION     %  CREATE FUNCTION public.check_password(iuser_index integer, ipassword text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare res boolean;
begin
	select u.user_password = crypt(ipassword, u.user_password) into res
	from admin.users u
	where user_index = iuser_index;
	return res;
end;
$$;
 J   DROP FUNCTION public.check_password(iuser_index integer, ipassword text);
       public          postgres    false            P           1255    232911    check_password(text, text)    FUNCTION     8  CREATE FUNCTION public.check_password(ilogin text, ipassword text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
--проверка пароля
declare res boolean;
begin
	select u.user_password = crypt(ipassword, u.user_password) into res
	from admin.users u
	where user_login = ilogin;
	return res;
end;
$$;
 B   DROP FUNCTION public.check_password(ilogin text, ipassword text);
       public          postgres    false            ^           1255    232993    get_all_roles_list()    FUNCTION       CREATE FUNCTION public.get_all_roles_list() RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
select json_agg(json_build_object('role_index', role_index,
								  'role_name', role_name, 'role_fullname', role_fullname))
								  into res
from admin.roles;
end;
$$;
 +   DROP FUNCTION public.get_all_roles_list();
       public          postgres    false                       1255    232984    get_department_tree(integer)    FUNCTION     �  CREATE FUNCTION public.get_department_tree(idep_index integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare res refcursor;
begin
open res for 
	select dep_index, dep_name from(
	select dep_index, dep_name, rn from admin.dep_tree
	union all
	select dep_index, dep_name ,-1 as rn
	from admin.dep_tree where dep_index =idep_index
	union all 
	select null as dep_index, '------No departiment----' as dep_name, 0 as rn) a
	order by rn;
return res;
end;
$$;
 >   DROP FUNCTION public.get_department_tree(idep_index integer);
       public          postgres    false            d           1255    232975     get_json_fulldata(text, integer)    FUNCTION     �  CREATE FUNCTION public.get_json_fulldata(iuser_login text, irole_index integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
declare res json;
begin
select json_build_object('User',json_build_object('user_index', u.user_index, 'user_login', user_login,
						  'dep_index', dep_index, 'user_properties', user_properties) ,
						 'Role', json_build_object('role_index', r.role_index, 
						'role_name', role_name, 'role_fullname', role_fullname)) into res
from admin.users u, admin.roles r, admin.userroles x
where user_login = iuser_login and r.role_index = irole_index 
and r.role_index = x.role_index and u.user_index = x.user_index;
return res;
end;
$$;
 O   DROP FUNCTION public.get_json_fulldata(iuser_login text, irole_index integer);
       public          postgres    false            ]           1255    232960    test3()    FUNCTION     �   CREATE FUNCTION public.test3() RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare res integer;
begin
select tid from test into res where tid = 100;
return coalesce(res, 0);
end;
$$;
    DROP FUNCTION public.test3();
       public          postgres    false            �            1259    232698    departments    TABLE     �   CREATE TABLE admin.departments (
    dep_index integer NOT NULL,
    dep_dep_index integer,
    dep_name text NOT NULL,
    dep_properties json,
    dep_nn integer
);
    DROP TABLE admin.departments;
       admin            postgres    false    9            �           0    0    TABLE departments    COMMENT     >   COMMENT ON TABLE admin.departments IS 'Table of departments';
          admin          postgres    false    202            �           0    0    COLUMN departments.dep_index    COMMENT     H   COMMENT ON COLUMN admin.departments.dep_index IS 'Index of department';
          admin          postgres    false    202            �           0    0     COLUMN departments.dep_dep_index    COMMENT     S   COMMENT ON COLUMN admin.departments.dep_dep_index IS 'Index of parent department';
          admin          postgres    false    202            �           0    0    COLUMN departments.dep_name    COMMENT     F   COMMENT ON COLUMN admin.departments.dep_name IS 'Name of department';
          admin          postgres    false    202            �           0    0 !   COLUMN departments.dep_properties    COMMENT     f   COMMENT ON COLUMN admin.departments.dep_properties IS 'List for additional properties of department';
          admin          postgres    false    202            �            1259    232977    dep_tree    VIEW     �  CREATE VIEW admin.dep_tree AS
 WITH RECURSIVE r AS (
         SELECT departments.dep_index,
            departments.dep_name,
            1 AS lev,
            ARRAY[departments.dep_nn] AS path
           FROM admin.departments
          WHERE (departments.dep_dep_index IS NULL)
        UNION
         SELECT x.dep_index,
            x.dep_name,
            (1 + r_1.lev) AS lev,
            (r_1.path || x.dep_nn) AS path
           FROM admin.departments x,
            r r_1
          WHERE (x.dep_dep_index = r_1.dep_index)
        )
 SELECT r.dep_index,
    lpad(r.dep_name, ((5 * (r.lev - 1)) + length(r.dep_name))) AS dep_name,
    row_number() OVER (ORDER BY r.path) AS rn
   FROM r
  ORDER BY r.path;
    DROP VIEW admin.dep_tree;
       admin          postgres    false    202    202    202    202    9            �            1259    232696    departments_dep_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.departments_dep_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE admin.departments_dep_index_seq;
       admin          postgres    false    9    202            �           0    0    departments_dep_index_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE admin.departments_dep_index_seq OWNED BY admin.departments.dep_index;
          admin          postgres    false    201            �            1259    232822    funcblockresources    TABLE     i   CREATE TABLE admin.funcblockresources (
    fb_index integer NOT NULL,
    res_index integer NOT NULL
);
 %   DROP TABLE admin.funcblockresources;
       admin            postgres    false    9            �           0    0    TABLE funcblockresources    COMMENT     l   COMMENT ON TABLE admin.funcblockresources IS 'Corresponding table between functional blocks and resources';
          admin          postgres    false    215            �           0    0 "   COLUMN funcblockresources.fb_index    COMMENT     T   COMMENT ON COLUMN admin.funcblockresources.fb_index IS 'Index of functional block';
          admin          postgres    false    215            �           0    0 #   COLUMN funcblockresources.res_index    COMMENT     M   COMMENT ON COLUMN admin.funcblockresources.res_index IS 'Index of resource';
          admin          postgres    false    215            �            1259    232807    funcblockroles    TABLE     f   CREATE TABLE admin.funcblockroles (
    fb_index integer NOT NULL,
    role_index integer NOT NULL
);
 !   DROP TABLE admin.funcblockroles;
       admin            postgres    false    9            �           0    0    TABLE funcblockroles    COMMENT     d   COMMENT ON TABLE admin.funcblockroles IS 'Corresponding table between functional blocks and roles';
          admin          postgres    false    214            �           0    0    COLUMN funcblockroles.fb_index    COMMENT     P   COMMENT ON COLUMN admin.funcblockroles.fb_index IS 'Index of functional block';
          admin          postgres    false    214            �           0    0     COLUMN funcblockroles.role_index    COMMENT     F   COMMENT ON COLUMN admin.funcblockroles.role_index IS 'Index of role';
          admin          postgres    false    214            �            1259    232796 
   funcblocks    TABLE     |   CREATE TABLE admin.funcblocks (
    fb_index integer NOT NULL,
    fb_name text,
    fb_fullname text,
    fb_nn integer
);
    DROP TABLE admin.funcblocks;
       admin            postgres    false    9            �           0    0    TABLE funcblocks    COMMENT     E   COMMENT ON TABLE admin.funcblocks IS 'Table of blocks of functions';
          admin          postgres    false    213            �           0    0    COLUMN funcblocks.fb_index    COMMENT     A   COMMENT ON COLUMN admin.funcblocks.fb_index IS 'Index of block';
          admin          postgres    false    213            �           0    0    COLUMN funcblocks.fb_name    COMMENT     ?   COMMENT ON COLUMN admin.funcblocks.fb_name IS 'Name of block';
          admin          postgres    false    213            �           0    0    COLUMN funcblocks.fb_fullname    COMMENT     H   COMMENT ON COLUMN admin.funcblocks.fb_fullname IS 'Full name of block';
          admin          postgres    false    213            �            1259    232794    funcblocks_fb_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.funcblocks_fb_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE admin.funcblocks_fb_index_seq;
       admin          postgres    false    213    9            �           0    0    funcblocks_fb_index_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE admin.funcblocks_fb_index_seq OWNED BY admin.funcblocks.fb_index;
          admin          postgres    false    212            �            1259    232773 	   resources    TABLE     �   CREATE TABLE admin.resources (
    res_index integer NOT NULL,
    res_res_index integer,
    res_name text NOT NULL,
    res_fullname text,
    rtp_index integer,
    res_nn integer
);
    DROP TABLE admin.resources;
       admin            postgres    false    9            �           0    0    TABLE resources    COMMENT     :   COMMENT ON TABLE admin.resources IS 'Table of resources';
          admin          postgres    false    211            �           0    0    COLUMN resources.res_index    COMMENT     D   COMMENT ON COLUMN admin.resources.res_index IS 'Index of resource';
          admin          postgres    false    211            �           0    0    COLUMN resources.res_res_index    COMMENT     O   COMMENT ON COLUMN admin.resources.res_res_index IS 'Index of parent resource';
          admin          postgres    false    211            �           0    0    COLUMN resources.res_name    COMMENT     B   COMMENT ON COLUMN admin.resources.res_name IS 'Name of resource';
          admin          postgres    false    211            �           0    0    COLUMN resources.res_fullname    COMMENT     K   COMMENT ON COLUMN admin.resources.res_fullname IS 'Full name of resource';
          admin          postgres    false    211            �           0    0    COLUMN resources.rtp_index    COMMENT     L   COMMENT ON COLUMN admin.resources.rtp_index IS 'Index of type of resource';
          admin          postgres    false    211            �            1259    232771    resources_res_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.resources_res_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE admin.resources_res_index_seq;
       admin          postgres    false    9    211            �           0    0    resources_res_index_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE admin.resources_res_index_seq OWNED BY admin.resources.res_index;
          admin          postgres    false    210            �            1259    232760    resourcetypes    TABLE     �   CREATE TABLE admin.resourcetypes (
    rtp_index integer NOT NULL,
    rtp_name text NOT NULL,
    rtp_fullname text,
    is_visible boolean,
    rtp_nn integer
);
     DROP TABLE admin.resourcetypes;
       admin            postgres    false    9            �           0    0    TABLE resourcetypes    COMMENT     G   COMMENT ON TABLE admin.resourcetypes IS 'Table of types of resources';
          admin          postgres    false    209            �           0    0    COLUMN resourcetypes.rtp_index    COMMENT     D   COMMENT ON COLUMN admin.resourcetypes.rtp_index IS 'Index of type';
          admin          postgres    false    209            �           0    0    COLUMN resourcetypes.rtp_name    COMMENT     B   COMMENT ON COLUMN admin.resourcetypes.rtp_name IS 'Name of type';
          admin          postgres    false    209            �           0    0 !   COLUMN resourcetypes.rtp_fullname    COMMENT     K   COMMENT ON COLUMN admin.resourcetypes.rtp_fullname IS 'Full name of type';
          admin          postgres    false    209            �            1259    232758    resourcetypes_rtp_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.resourcetypes_rtp_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE admin.resourcetypes_rtp_index_seq;
       admin          postgres    false    209    9            �           0    0    resourcetypes_rtp_index_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE admin.resourcetypes_rtp_index_seq OWNED BY admin.resourcetypes.rtp_index;
          admin          postgres    false    208            �            1259    232732    roles    TABLE     �   CREATE TABLE admin.roles (
    role_index integer NOT NULL,
    role_name text NOT NULL,
    role_fullname text,
    role_nn integer
);
    DROP TABLE admin.roles;
       admin            postgres    false    9            �           0    0    TABLE roles    COMMENT     2   COMMENT ON TABLE admin.roles IS 'Table of roles';
          admin          postgres    false    206            �           0    0    COLUMN roles.role_index    COMMENT     =   COMMENT ON COLUMN admin.roles.role_index IS 'Index of role';
          admin          postgres    false    206            �           0    0    COLUMN roles.role_name    COMMENT     ;   COMMENT ON COLUMN admin.roles.role_name IS 'Name of role';
          admin          postgres    false    206            �           0    0    COLUMN roles.role_fullname    COMMENT     D   COMMENT ON COLUMN admin.roles.role_fullname IS 'Full name of role';
          admin          postgres    false    206            �            1259    232730    roles_role_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.roles_role_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE admin.roles_role_index_seq;
       admin          postgres    false    206    9            �           0    0    roles_role_index_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE admin.roles_role_index_seq OWNED BY admin.roles.role_index;
          admin          postgres    false    205            �            1259    232743 	   userroles    TABLE     c   CREATE TABLE admin.userroles (
    user_index integer NOT NULL,
    role_index integer NOT NULL
);
    DROP TABLE admin.userroles;
       admin            postgres    false    9            �           0    0    TABLE userroles    COMMENT     S   COMMENT ON TABLE admin.userroles IS 'Corresponding table between users and roles';
          admin          postgres    false    207            �           0    0    COLUMN userroles.user_index    COMMENT     A   COMMENT ON COLUMN admin.userroles.user_index IS 'Index of user';
          admin          postgres    false    207            �           0    0    COLUMN userroles.role_index    COMMENT     A   COMMENT ON COLUMN admin.userroles.role_index IS 'Index of role';
          admin          postgres    false    207            �            1259    232714    users    TABLE     �   CREATE TABLE admin.users (
    user_index integer NOT NULL,
    dep_index integer,
    user_login text NOT NULL,
    user_password text NOT NULL,
    user_properties json,
    user_nn integer
);
    DROP TABLE admin.users;
       admin            postgres    false    9            �           0    0    TABLE users    COMMENT     2   COMMENT ON TABLE admin.users IS 'Table of users';
          admin          postgres    false    204            �           0    0    COLUMN users.user_index    COMMENT     =   COMMENT ON COLUMN admin.users.user_index IS 'Index of user';
          admin          postgres    false    204            �           0    0    COLUMN users.dep_index    COMMENT     A   COMMENT ON COLUMN admin.users.dep_index IS 'User''s department';
          admin          postgres    false    204            �           0    0    COLUMN users.user_login    COMMENT     5   COMMENT ON COLUMN admin.users.user_login IS 'Login';
          admin          postgres    false    204            �           0    0    COLUMN users.user_password    COMMENT     ;   COMMENT ON COLUMN admin.users.user_password IS 'Password';
          admin          postgres    false    204            �           0    0    COLUMN users.user_properties    COMMENT     [   COMMENT ON COLUMN admin.users.user_properties IS 'List for additional properties of user';
          admin          postgres    false    204            �            1259    232712    users_user_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.users_user_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE admin.users_user_index_seq;
       admin          postgres    false    9    204            �           0    0    users_user_index_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE admin.users_user_index_seq OWNED BY admin.users.user_index;
          admin          postgres    false    203            �            1259    232839    usersessions    TABLE     �   CREATE TABLE admin.usersessions (
    uss_index integer NOT NULL,
    user_index integer NOT NULL,
    role_index integer NOT NULL,
    date_beg timestamp without time zone NOT NULL,
    date_end timestamp without time zone,
    uss_url inet
);
    DROP TABLE admin.usersessions;
       admin            postgres    false    9            �           0    0    TABLE usersessions    COMMENT     <   COMMENT ON TABLE admin.usersessions IS 'Table of sessions';
          admin          postgres    false    217            �           0    0    COLUMN usersessions.uss_index    COMMENT     F   COMMENT ON COLUMN admin.usersessions.uss_index IS 'Index of session';
          admin          postgres    false    217            �           0    0    COLUMN usersessions.user_index    COMMENT     D   COMMENT ON COLUMN admin.usersessions.user_index IS 'Index of user';
          admin          postgres    false    217            �           0    0    COLUMN usersessions.role_index    COMMENT     D   COMMENT ON COLUMN admin.usersessions.role_index IS 'Index of role';
          admin          postgres    false    217            �           0    0    COLUMN usersessions.date_beg    COMMENT     Q   COMMENT ON COLUMN admin.usersessions.date_beg IS 'Starting time of the session';
          admin          postgres    false    217            �           0    0    COLUMN usersessions.date_end    COMMENT     R   COMMENT ON COLUMN admin.usersessions.date_end IS 'Finishing time of the session';
          admin          postgres    false    217            �           0    0    COLUMN usersessions.uss_url    COMMENT     ?   COMMENT ON COLUMN admin.usersessions.uss_url IS 'User''s URL';
          admin          postgres    false    217            �            1259    232837    usersessions_uss_index_seq    SEQUENCE     �   CREATE SEQUENCE admin.usersessions_uss_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE admin.usersessions_uss_index_seq;
       admin          postgres    false    9    217            �           0    0    usersessions_uss_index_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE admin.usersessions_uss_index_seq OWNED BY admin.usersessions.uss_index;
          admin          postgres    false    216            �            1259    233190 	   addresses    TABLE     '  CREATE TABLE public.addresses (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    user_id integer,
    contact_name text,
    phone text,
    city text,
    address1 text,
    address2 text
);
    DROP TABLE public.addresses;
       public            postgres    false            �            1259    233188    addresses_id_seq    SEQUENCE     �   CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.addresses_id_seq;
       public          postgres    false    250            �           0    0    addresses_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;
          public          postgres    false    249                       1259    233324    articles    TABLE     �  CREATE TABLE public.articles (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    author_id integer,
    title text,
    content text,
    version_name character varying(128) NOT NULL,
    version_priority text,
    scheduled_start_at timestamp with time zone,
    scheduled_end_at timestamp with time zone,
    scheduled_event_id integer,
    publish_ready boolean
);
    DROP TABLE public.articles;
       public            postgres    false                       1259    233322    articles_id_seq    SEQUENCE     �   CREATE SEQUENCE public.articles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.articles_id_seq;
       public          postgres    false    271            �           0    0    articles_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.articles_id_seq OWNED BY public.articles.id;
          public          postgres    false    270            �            1259    233026    asset_managers    TABLE     �   CREATE TABLE public.asset_managers (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    file text
);
 "   DROP TABLE public.asset_managers;
       public            postgres    false            �            1259    233024    asset_managers_id_seq    SEQUENCE     �   CREATE SEQUENCE public.asset_managers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.asset_managers_id_seq;
       public          postgres    false    223            �           0    0    asset_managers_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.asset_managers_id_seq OWNED BY public.asset_managers.id;
          public          postgres    false    222            �            1259    233007    auth_identities    TABLE     K  CREATE TABLE public.auth_identities (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    provider text,
    uid text,
    encrypted_password text,
    user_id text,
    confirmed_at timestamp with time zone,
    sign_logs text
);
 #   DROP TABLE public.auth_identities;
       public            postgres    false            �            1259    233005    auth_identities_id_seq    SEQUENCE     �   CREATE SEQUENCE public.auth_identities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.auth_identities_id_seq;
       public          postgres    false    220            �           0    0    auth_identities_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.auth_identities_id_seq OWNED BY public.auth_identities.id;
          public          postgres    false    219            �            1259    233154 
   categories    TABLE     8  CREATE TABLE public.categories (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    language_code character varying(20) NOT NULL,
    "position" integer,
    name text,
    code text,
    category_id integer
);
    DROP TABLE public.categories;
       public            postgres    false            �            1259    233152    categories_id_seq    SEQUENCE     �   CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.categories_id_seq;
       public          postgres    false    244            �           0    0    categories_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;
          public          postgres    false    243            �            1259    233166    collections    TABLE     �   CREATE TABLE public.collections (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    name text,
    language_code character varying(20) NOT NULL
);
    DROP TABLE public.collections;
       public            postgres    false            �            1259    233164    collections_id_seq    SEQUENCE     �   CREATE SEQUENCE public.collections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.collections_id_seq;
       public          postgres    false    246            �           0    0    collections_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.collections_id_seq OWNED BY public.collections.id;
          public          postgres    false    245            �            1259    233094    color_variation_images    TABLE       CREATE TABLE public.color_variation_images (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    color_variation_id integer,
    image character varying(4096)
);
 *   DROP TABLE public.color_variation_images;
       public            postgres    false            �            1259    233092    color_variation_images_id_seq    SEQUENCE     �   CREATE SEQUENCE public.color_variation_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.color_variation_images_id_seq;
       public          postgres    false    234            �           0    0    color_variation_images_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.color_variation_images_id_seq OWNED BY public.color_variation_images.id;
          public          postgres    false    233            �            1259    233082    color_variations    TABLE     C  CREATE TABLE public.color_variations (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    product_id integer,
    color_id integer,
    color_code text,
    images text,
    version_name character varying(128) NOT NULL
);
 $   DROP TABLE public.color_variations;
       public            postgres    false            �            1259    233080    color_variations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.color_variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.color_variations_id_seq;
       public          postgres    false    232            �           0    0    color_variations_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.color_variations_id_seq OWNED BY public.color_variations.id;
          public          postgres    false    231            �            1259    233115    colors    TABLE       CREATE TABLE public.colors (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    language_code character varying(20) NOT NULL,
    "position" integer,
    name text,
    code text,
    version_name character varying(128) NOT NULL,
    version_priority text,
    scheduled_start_at timestamp with time zone,
    scheduled_end_at timestamp with time zone,
    scheduled_event_id integer,
    publish_ready boolean
);
    DROP TABLE public.colors;
       public            postgres    false            �            1259    233113    colors_id_seq    SEQUENCE     �   CREATE SEQUENCE public.colors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.colors_id_seq;
       public          postgres    false    238            �           0    0    colors_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.colors_id_seq OWNED BY public.colors.id;
          public          postgres    false    237                        1259    233226    delivery_methods    TABLE     �   CREATE TABLE public.delivery_methods (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    name text,
    price numeric
);
 $   DROP TABLE public.delivery_methods;
       public            postgres    false            �            1259    233224    delivery_methods_id_seq    SEQUENCE     �   CREATE SEQUENCE public.delivery_methods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.delivery_methods_id_seq;
       public          postgres    false    256            �           0    0    delivery_methods_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.delivery_methods_id_seq OWNED BY public.delivery_methods.id;
          public          postgres    false    255            �            1259    233142 	   materials    TABLE       CREATE TABLE public.materials (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    language_code character varying(20) NOT NULL,
    name text,
    code text
);
    DROP TABLE public.materials;
       public            postgres    false            �            1259    233140    materials_id_seq    SEQUENCE     �   CREATE SEQUENCE public.materials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.materials_id_seq;
       public          postgres    false    242            �           0    0    materials_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.materials_id_seq OWNED BY public.materials.id;
          public          postgres    false    241                       1259    233262    media_libraries    TABLE     �   CREATE TABLE public.media_libraries (
    title text,
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    selected_type text,
    file text
);
 #   DROP TABLE public.media_libraries;
       public            postgres    false                       1259    233260    media_libraries_id_seq    SEQUENCE     �   CREATE SEQUENCE public.media_libraries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.media_libraries_id_seq;
       public          postgres    false    262            �           0    0    media_libraries_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.media_libraries_id_seq OWNED BY public.media_libraries.id;
          public          postgres    false    261                       1259    233337    my_seo_settings    TABLE       CREATE TABLE public.my_seo_settings (
    name text NOT NULL,
    setting text,
    is_global_seo boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    language_code character varying(20) NOT NULL
);
 #   DROP TABLE public.my_seo_settings;
       public            postgres    false            �            1259    233214    order_items    TABLE     A  CREATE TABLE public.order_items (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    order_id integer,
    size_variation_id integer,
    quantity integer,
    price numeric,
    discount_rate integer,
    state text
);
    DROP TABLE public.order_items;
       public            postgres    false            �            1259    233212    order_items_id_seq    SEQUENCE     �   CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.order_items_id_seq;
       public          postgres    false    254            �           0    0    order_items_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;
          public          postgres    false    253            �            1259    233202    orders    TABLE       CREATE TABLE public.orders (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    user_id integer,
    payment_amount numeric,
    payment_total numeric,
    abandoned_reason text,
    discount_value integer,
    delivery_method_id integer,
    payment_method text,
    tracking_number text,
    shipped_at timestamp with time zone,
    returned_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    shipping_address_id integer,
    billing_address_id integer,
    amazon_address_access_token text,
    amazon_order_reference_id text,
    amazon_authorization_id text,
    amazon_capture_id text,
    amazon_refund_id text,
    payment_log text,
    state text
);
    DROP TABLE public.orders;
       public            postgres    false            �            1259    233200    orders_id_seq    SEQUENCE     �   CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.orders_id_seq;
       public          postgres    false    252            �           0    0    orders_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;
          public          postgres    false    251                       1259    233309    pages    TABLE     �  CREATE TABLE public.pages (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    title text,
    title_with_slug text,
    containers text,
    version_name character varying(128) NOT NULL,
    version_priority text,
    scheduled_start_at timestamp with time zone,
    scheduled_end_at timestamp with time zone,
    scheduled_event_id integer,
    publish_ready boolean
);
    DROP TABLE public.pages;
       public            postgres    false                       1259    233307    pages_id_seq    SEQUENCE     �   CREATE SEQUENCE public.pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.pages_id_seq;
       public          postgres    false    269            �           0    0    pages_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.pages_id_seq OWNED BY public.pages.id;
          public          postgres    false    268            �            1259    233036    product_collections    TABLE     "  CREATE TABLE public.product_collections (
    product_id integer NOT NULL,
    product_language_code character varying(20) NOT NULL,
    product_version_name character varying(128) NOT NULL,
    collection_id integer NOT NULL,
    collection_language_code character varying(20) NOT NULL
);
 '   DROP TABLE public.product_collections;
       public            postgres    false            �            1259    233070    product_images    TABLE     !  CREATE TABLE public.product_images (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    title text,
    color_id integer,
    category_id integer,
    selected_type text,
    file text
);
 "   DROP TABLE public.product_images;
       public            postgres    false            �            1259    233068    product_images_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.product_images_id_seq;
       public          postgres    false    230            �           0    0    product_images_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.product_images_id_seq OWNED BY public.product_images.id;
          public          postgres    false    229            �            1259    233058    product_variations    TABLE     �  CREATE TABLE public.product_variations (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    product_id integer,
    color_id integer,
    size_id integer,
    material_id integer,
    sku text,
    receipt_name text,
    featured boolean,
    price integer,
    selling_price integer,
    available_quantity integer,
    images text
);
 &   DROP TABLE public.product_variations;
       public            postgres    false            �            1259    233056    product_variations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.product_variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.product_variations_id_seq;
       public          postgres    false    228            �           0    0    product_variations_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.product_variations_id_seq OWNED BY public.product_variations.id;
          public          postgres    false    227            �            1259    233043    products    TABLE       CREATE TABLE public.products (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    language_code character varying(20) NOT NULL,
    "position" integer,
    name text,
    name_with_slug text,
    featured boolean,
    code text,
    category_id integer,
    made_country text,
    gender text,
    main_image text,
    price numeric,
    description character varying(2000),
    color_variations_sorter text,
    product_properties text,
    seo text,
    version_name character varying(128) NOT NULL,
    version_priority text,
    scheduled_start_at timestamp with time zone,
    scheduled_end_at timestamp with time zone,
    scheduled_event_id integer,
    publish_ready boolean
);
    DROP TABLE public.products;
       public            postgres    false            �            1259    233041    products_id_seq    SEQUENCE     �   CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.products_id_seq;
       public          postgres    false    226            �           0    0    products_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;
          public          postgres    false    225            
           1259    233286    qor_activities    TABLE     �  CREATE TABLE public.qor_activities (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    action text,
    content character varying(5000),
    note character varying(2000),
    type text,
    resource_type text,
    resource_id text,
    creator_name text,
    created_by text,
    updated_by text
);
 "   DROP TABLE public.qor_activities;
       public            postgres    false            	           1259    233284    qor_activities_id_seq    SEQUENCE     �   CREATE SEQUENCE public.qor_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public.qor_activities_id_seq;
       public          postgres    false    266            �           0    0    qor_activities_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public.qor_activities_id_seq OWNED BY public.qor_activities.id;
          public          postgres    false    265                       1259    233372    qor_admin_settings    TABLE       CREATE TABLE public.qor_admin_settings (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    key text,
    resource text,
    user_id text,
    value text
);
 &   DROP TABLE public.qor_admin_settings;
       public            postgres    false                       1259    233370    qor_admin_settings_id_seq    SEQUENCE     �   CREATE SEQUENCE public.qor_admin_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.qor_admin_settings_id_seq;
       public          postgres    false    278            �           0    0    qor_admin_settings_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.qor_admin_settings_id_seq OWNED BY public.qor_admin_settings.id;
          public          postgres    false    277                       1259    233360    qor_banner_editor_settings    TABLE     �   CREATE TABLE public.qor_banner_editor_settings (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    kind text,
    value text
);
 .   DROP TABLE public.qor_banner_editor_settings;
       public            postgres    false                       1259    233358 !   qor_banner_editor_settings_id_seq    SEQUENCE     �   CREATE SEQUENCE public.qor_banner_editor_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.qor_banner_editor_settings_id_seq;
       public          postgres    false    276            �           0    0 !   qor_banner_editor_settings_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.qor_banner_editor_settings_id_seq OWNED BY public.qor_banner_editor_settings.id;
          public          postgres    false    275                       1259    233348    qor_help_entries    TABLE     �   CREATE TABLE public.qor_help_entries (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    title text,
    categories text,
    body text
);
 $   DROP TABLE public.qor_help_entries;
       public            postgres    false                       1259    233346    qor_help_entries_id_seq    SEQUENCE     �   CREATE SEQUENCE public.qor_help_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.qor_help_entries_id_seq;
       public          postgres    false    274            �           0    0    qor_help_entries_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.qor_help_entries_id_seq OWNED BY public.qor_help_entries.id;
          public          postgres    false    273                       1259    233408    qor_jobs    TABLE     w  CREATE TABLE public.qor_jobs (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    status text DEFAULT 'new'::text,
    progress integer,
    progress_text text,
    log text,
    results_table text,
    created_by text,
    updated_by text,
    kind text,
    value text
);
    DROP TABLE public.qor_jobs;
       public            postgres    false                       1259    233406    qor_jobs_id_seq    SEQUENCE     �   CREATE SEQUENCE public.qor_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.qor_jobs_id_seq;
       public          postgres    false    284            �           0    0    qor_jobs_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.qor_jobs_id_seq OWNED BY public.qor_jobs.id;
          public          postgres    false    283                       1259    233396    qor_notifications    TABLE     >  CREATE TABLE public.qor_notifications (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    "from" text,
    "to" text,
    title text,
    body text,
    message_type text,
    resolved_at timestamp with time zone
);
 %   DROP TABLE public.qor_notifications;
       public            postgres    false                       1259    233394    qor_notifications_id_seq    SEQUENCE     �   CREATE SEQUENCE public.qor_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.qor_notifications_id_seq;
       public          postgres    false    282            �           0    0    qor_notifications_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.qor_notifications_id_seq OWNED BY public.qor_notifications.id;
          public          postgres    false    281                       1259    233296    qor_widget_settings    TABLE     M  CREATE TABLE public.qor_widget_settings (
    name character varying(100) NOT NULL,
    scope character varying(128) DEFAULT 'default'::character varying NOT NULL,
    source_type character varying(100) DEFAULT ''::character varying NOT NULL,
    source_id character varying(100) DEFAULT ''::character varying NOT NULL,
    description text,
    shared boolean,
    widget_type text,
    group_name text,
    template text,
    kind text,
    value text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    language_code character varying(20) NOT NULL
);
 '   DROP TABLE public.qor_widget_settings;
       public            postgres    false                       1259    233384    scheduled_events    TABLE     ,  CREATE TABLE public.scheduled_events (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    name text,
    scheduled_start_at timestamp with time zone,
    scheduled_end_at timestamp with time zone
);
 $   DROP TABLE public.scheduled_events;
       public            postgres    false                       1259    233382    scheduled_events_id_seq    SEQUENCE     �   CREATE SEQUENCE public.scheduled_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.scheduled_events_id_seq;
       public          postgres    false    280            �           0    0    scheduled_events_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.scheduled_events_id_seq OWNED BY public.scheduled_events.id;
          public          postgres    false    279                       1259    233250    settings    TABLE     �  CREATE TABLE public.settings (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    shipping_fee integer,
    gift_wrapping_fee integer,
    cod_fee integer,
    tax_rate integer,
    address text,
    city text,
    region text,
    country text,
    zip text,
    latitude numeric,
    longitude numeric,
    language_code character varying(20) NOT NULL
);
    DROP TABLE public.settings;
       public            postgres    false                       1259    233248    settings_id_seq    SEQUENCE     �   CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.settings_id_seq;
       public          postgres    false    260            �           0    0    settings_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;
          public          postgres    false    259            �            1259    233106    size_variations    TABLE     C  CREATE TABLE public.size_variations (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    color_variation_id integer,
    size_id integer,
    available_quantity integer,
    version_name character varying(128) NOT NULL
);
 #   DROP TABLE public.size_variations;
       public            postgres    false            �            1259    233104    size_variations_id_seq    SEQUENCE     �   CREATE SEQUENCE public.size_variations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.size_variations_id_seq;
       public          postgres    false    236            �           0    0    size_variations_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.size_variations_id_seq OWNED BY public.size_variations.id;
          public          postgres    false    235            �            1259    233130    sizes    TABLE       CREATE TABLE public.sizes (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    language_code character varying(20) NOT NULL,
    "position" integer,
    name text,
    code text
);
    DROP TABLE public.sizes;
       public            postgres    false            �            1259    233128    sizes_id_seq    SEQUENCE     �   CREATE SEQUENCE public.sizes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.sizes_id_seq;
       public          postgres    false    240            �           0    0    sizes_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.sizes_id_seq OWNED BY public.sizes.id;
          public          postgres    false    239                       1259    233274    state_change_logs    TABLE     S  CREATE TABLE public.state_change_logs (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    refer_table text,
    refer_id text,
    "from" text,
    "to" text,
    note character varying(1024),
    created_by text,
    updated_by text
);
 %   DROP TABLE public.state_change_logs;
       public            postgres    false                       1259    233272    state_change_logs_id_seq    SEQUENCE     �   CREATE SEQUENCE public.state_change_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.state_change_logs_id_seq;
       public          postgres    false    264            �           0    0    state_change_logs_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public.state_change_logs_id_seq OWNED BY public.state_change_logs.id;
          public          postgres    false    263                       1259    233238    stores    TABLE     �  CREATE TABLE public.stores (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    store_name text,
    owner text,
    phone text,
    email text,
    address text,
    city text,
    region text,
    country text,
    zip text,
    latitude numeric,
    longitude numeric,
    "position" integer
);
    DROP TABLE public.stores;
       public            postgres    false                       1259    233236    stores_id_seq    SEQUENCE     �   CREATE SEQUENCE public.stores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.stores_id_seq;
       public          postgres    false    258            �           0    0    stores_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.stores_id_seq OWNED BY public.stores.id;
          public          postgres    false    257            �            1259    232034    test    TABLE     E   CREATE TABLE public.test (
    tid integer NOT NULL,
    val text
);
    DROP TABLE public.test;
       public            postgres    false            �            1259    232685    test2    TABLE     A   CREATE TABLE public.test2 (
    t1 text NOT NULL,
    t2 text
);
    DROP TABLE public.test2;
       public            postgres    false            �            1259    232032    test_tid_seq    SEQUENCE     �   CREATE SEQUENCE public.test_tid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.test_tid_seq;
       public          postgres    false    199            �           0    0    test_tid_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.test_tid_seq OWNED BY public.test.tid;
          public          postgres    false    198            �            1259    233017    translations    TABLE     e   CREATE TABLE public.translations (
    locale character varying(12),
    key text,
    value text
);
     DROP TABLE public.translations;
       public            postgres    false            �            1259    233178    users    TABLE     g  CREATE TABLE public.users (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    email text,
    password text,
    name text,
    gender text,
    role text,
    birthday timestamp with time zone,
    balance numeric,
    default_billing_address integer,
    default_shipping_address integer,
    avatar text,
    confirm_token text,
    confirmed boolean,
    recover_token text,
    recover_token_expiry timestamp with time zone,
    accept_private boolean,
    accept_license boolean,
    accept_news boolean
);
    DROP TABLE public.users;
       public            postgres    false            �            1259    233176    users_id_seq    SEQUENCE     �   CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.users_id_seq;
       public          postgres    false    248            �           0    0    users_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;
          public          postgres    false    247            �           2604    232701    departments dep_index    DEFAULT     |   ALTER TABLE ONLY admin.departments ALTER COLUMN dep_index SET DEFAULT nextval('admin.departments_dep_index_seq'::regclass);
 C   ALTER TABLE admin.departments ALTER COLUMN dep_index DROP DEFAULT;
       admin          postgres    false    201    202    202                       2604    232799    funcblocks fb_index    DEFAULT     x   ALTER TABLE ONLY admin.funcblocks ALTER COLUMN fb_index SET DEFAULT nextval('admin.funcblocks_fb_index_seq'::regclass);
 A   ALTER TABLE admin.funcblocks ALTER COLUMN fb_index DROP DEFAULT;
       admin          postgres    false    212    213    213                       2604    232776    resources res_index    DEFAULT     x   ALTER TABLE ONLY admin.resources ALTER COLUMN res_index SET DEFAULT nextval('admin.resources_res_index_seq'::regclass);
 A   ALTER TABLE admin.resources ALTER COLUMN res_index DROP DEFAULT;
       admin          postgres    false    211    210    211                        2604    232763    resourcetypes rtp_index    DEFAULT     �   ALTER TABLE ONLY admin.resourcetypes ALTER COLUMN rtp_index SET DEFAULT nextval('admin.resourcetypes_rtp_index_seq'::regclass);
 E   ALTER TABLE admin.resourcetypes ALTER COLUMN rtp_index DROP DEFAULT;
       admin          postgres    false    208    209    209            �           2604    232735    roles role_index    DEFAULT     r   ALTER TABLE ONLY admin.roles ALTER COLUMN role_index SET DEFAULT nextval('admin.roles_role_index_seq'::regclass);
 >   ALTER TABLE admin.roles ALTER COLUMN role_index DROP DEFAULT;
       admin          postgres    false    205    206    206            �           2604    232717    users user_index    DEFAULT     r   ALTER TABLE ONLY admin.users ALTER COLUMN user_index SET DEFAULT nextval('admin.users_user_index_seq'::regclass);
 >   ALTER TABLE admin.users ALTER COLUMN user_index DROP DEFAULT;
       admin          postgres    false    204    203    204                       2604    232842    usersessions uss_index    DEFAULT     ~   ALTER TABLE ONLY admin.usersessions ALTER COLUMN uss_index SET DEFAULT nextval('admin.usersessions_uss_index_seq'::regclass);
 D   ALTER TABLE admin.usersessions ALTER COLUMN uss_index DROP DEFAULT;
       admin          postgres    false    217    216    217                       2604    233193    addresses id    DEFAULT     l   ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);
 ;   ALTER TABLE public.addresses ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    249    250    250                       2604    233327    articles id    DEFAULT     j   ALTER TABLE ONLY public.articles ALTER COLUMN id SET DEFAULT nextval('public.articles_id_seq'::regclass);
 :   ALTER TABLE public.articles ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    270    271    271                       2604    233029    asset_managers id    DEFAULT     v   ALTER TABLE ONLY public.asset_managers ALTER COLUMN id SET DEFAULT nextval('public.asset_managers_id_seq'::regclass);
 @   ALTER TABLE public.asset_managers ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    223    223                       2604    233010    auth_identities id    DEFAULT     x   ALTER TABLE ONLY public.auth_identities ALTER COLUMN id SET DEFAULT nextval('public.auth_identities_id_seq'::regclass);
 A   ALTER TABLE public.auth_identities ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    220    220                       2604    233157    categories id    DEFAULT     n   ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);
 <   ALTER TABLE public.categories ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    243    244    244                       2604    233169    collections id    DEFAULT     p   ALTER TABLE ONLY public.collections ALTER COLUMN id SET DEFAULT nextval('public.collections_id_seq'::regclass);
 =   ALTER TABLE public.collections ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    246    245    246            
           2604    233097    color_variation_images id    DEFAULT     �   ALTER TABLE ONLY public.color_variation_images ALTER COLUMN id SET DEFAULT nextval('public.color_variation_images_id_seq'::regclass);
 H   ALTER TABLE public.color_variation_images ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    233    234    234            	           2604    233085    color_variations id    DEFAULT     z   ALTER TABLE ONLY public.color_variations ALTER COLUMN id SET DEFAULT nextval('public.color_variations_id_seq'::regclass);
 B   ALTER TABLE public.color_variations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    232    231    232                       2604    233118 	   colors id    DEFAULT     f   ALTER TABLE ONLY public.colors ALTER COLUMN id SET DEFAULT nextval('public.colors_id_seq'::regclass);
 8   ALTER TABLE public.colors ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    238    237    238                       2604    233229    delivery_methods id    DEFAULT     z   ALTER TABLE ONLY public.delivery_methods ALTER COLUMN id SET DEFAULT nextval('public.delivery_methods_id_seq'::regclass);
 B   ALTER TABLE public.delivery_methods ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    255    256    256                       2604    233145    materials id    DEFAULT     l   ALTER TABLE ONLY public.materials ALTER COLUMN id SET DEFAULT nextval('public.materials_id_seq'::regclass);
 ;   ALTER TABLE public.materials ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    241    242    242                       2604    233265    media_libraries id    DEFAULT     x   ALTER TABLE ONLY public.media_libraries ALTER COLUMN id SET DEFAULT nextval('public.media_libraries_id_seq'::regclass);
 A   ALTER TABLE public.media_libraries ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    262    261    262                       2604    233217    order_items id    DEFAULT     p   ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);
 =   ALTER TABLE public.order_items ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    253    254    254                       2604    233205 	   orders id    DEFAULT     f   ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);
 8   ALTER TABLE public.orders ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    252    251    252                       2604    233312    pages id    DEFAULT     d   ALTER TABLE ONLY public.pages ALTER COLUMN id SET DEFAULT nextval('public.pages_id_seq'::regclass);
 7   ALTER TABLE public.pages ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    269    268    269                       2604    233073    product_images id    DEFAULT     v   ALTER TABLE ONLY public.product_images ALTER COLUMN id SET DEFAULT nextval('public.product_images_id_seq'::regclass);
 @   ALTER TABLE public.product_images ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    230    229    230                       2604    233061    product_variations id    DEFAULT     ~   ALTER TABLE ONLY public.product_variations ALTER COLUMN id SET DEFAULT nextval('public.product_variations_id_seq'::regclass);
 D   ALTER TABLE public.product_variations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    227    228    228                       2604    233046    products id    DEFAULT     j   ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);
 :   ALTER TABLE public.products ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    225    226    226                       2604    233289    qor_activities id    DEFAULT     v   ALTER TABLE ONLY public.qor_activities ALTER COLUMN id SET DEFAULT nextval('public.qor_activities_id_seq'::regclass);
 @   ALTER TABLE public.qor_activities ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    265    266    266            "           2604    233375    qor_admin_settings id    DEFAULT     ~   ALTER TABLE ONLY public.qor_admin_settings ALTER COLUMN id SET DEFAULT nextval('public.qor_admin_settings_id_seq'::regclass);
 D   ALTER TABLE public.qor_admin_settings ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    277    278    278            !           2604    233363    qor_banner_editor_settings id    DEFAULT     �   ALTER TABLE ONLY public.qor_banner_editor_settings ALTER COLUMN id SET DEFAULT nextval('public.qor_banner_editor_settings_id_seq'::regclass);
 L   ALTER TABLE public.qor_banner_editor_settings ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    275    276    276                        2604    233351    qor_help_entries id    DEFAULT     z   ALTER TABLE ONLY public.qor_help_entries ALTER COLUMN id SET DEFAULT nextval('public.qor_help_entries_id_seq'::regclass);
 B   ALTER TABLE public.qor_help_entries ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    273    274    274            %           2604    233411    qor_jobs id    DEFAULT     j   ALTER TABLE ONLY public.qor_jobs ALTER COLUMN id SET DEFAULT nextval('public.qor_jobs_id_seq'::regclass);
 :   ALTER TABLE public.qor_jobs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    283    284    284            $           2604    233399    qor_notifications id    DEFAULT     |   ALTER TABLE ONLY public.qor_notifications ALTER COLUMN id SET DEFAULT nextval('public.qor_notifications_id_seq'::regclass);
 C   ALTER TABLE public.qor_notifications ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    282    281    282            #           2604    233387    scheduled_events id    DEFAULT     z   ALTER TABLE ONLY public.scheduled_events ALTER COLUMN id SET DEFAULT nextval('public.scheduled_events_id_seq'::regclass);
 B   ALTER TABLE public.scheduled_events ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    280    279    280                       2604    233253    settings id    DEFAULT     j   ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);
 :   ALTER TABLE public.settings ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    260    259    260                       2604    233109    size_variations id    DEFAULT     x   ALTER TABLE ONLY public.size_variations ALTER COLUMN id SET DEFAULT nextval('public.size_variations_id_seq'::regclass);
 A   ALTER TABLE public.size_variations ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    235    236    236                       2604    233133    sizes id    DEFAULT     d   ALTER TABLE ONLY public.sizes ALTER COLUMN id SET DEFAULT nextval('public.sizes_id_seq'::regclass);
 7   ALTER TABLE public.sizes ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    239    240    240                       2604    233277    state_change_logs id    DEFAULT     |   ALTER TABLE ONLY public.state_change_logs ALTER COLUMN id SET DEFAULT nextval('public.state_change_logs_id_seq'::regclass);
 C   ALTER TABLE public.state_change_logs ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    264    263    264                       2604    233241 	   stores id    DEFAULT     f   ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);
 8   ALTER TABLE public.stores ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    258    257    258            �           2604    232037    test tid    DEFAULT     d   ALTER TABLE ONLY public.test ALTER COLUMN tid SET DEFAULT nextval('public.test_tid_seq'::regclass);
 7   ALTER TABLE public.test ALTER COLUMN tid DROP DEFAULT;
       public          postgres    false    198    199    199                       2604    233181    users id    DEFAULT     d   ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);
 7   ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    248    247    248            F          0    232698    departments 
   TABLE DATA           `   COPY admin.departments (dep_index, dep_dep_index, dep_name, dep_properties, dep_nn) FROM stdin;
    admin          postgres    false    202   �j      S          0    232822    funcblockresources 
   TABLE DATA           @   COPY admin.funcblockresources (fb_index, res_index) FROM stdin;
    admin          postgres    false    215   k      R          0    232807    funcblockroles 
   TABLE DATA           =   COPY admin.funcblockroles (fb_index, role_index) FROM stdin;
    admin          postgres    false    214   jk      Q          0    232796 
   funcblocks 
   TABLE DATA           J   COPY admin.funcblocks (fb_index, fb_name, fb_fullname, fb_nn) FROM stdin;
    admin          postgres    false    213   �k      O          0    232773 	   resources 
   TABLE DATA           g   COPY admin.resources (res_index, res_res_index, res_name, res_fullname, rtp_index, res_nn) FROM stdin;
    admin          postgres    false    211    l      M          0    232760    resourcetypes 
   TABLE DATA           ]   COPY admin.resourcetypes (rtp_index, rtp_name, rtp_fullname, is_visible, rtp_nn) FROM stdin;
    admin          postgres    false    209   �m      J          0    232732    roles 
   TABLE DATA           M   COPY admin.roles (role_index, role_name, role_fullname, role_nn) FROM stdin;
    admin          postgres    false    206   An      K          0    232743 	   userroles 
   TABLE DATA           :   COPY admin.userroles (user_index, role_index) FROM stdin;
    admin          postgres    false    207   |n      H          0    232714    users 
   TABLE DATA           j   COPY admin.users (user_index, dep_index, user_login, user_password, user_properties, user_nn) FROM stdin;
    admin          postgres    false    204   �n      U          0    232839    usersessions 
   TABLE DATA           e   COPY admin.usersessions (uss_index, user_index, role_index, date_beg, date_end, uss_url) FROM stdin;
    admin          postgres    false    217   pp      u          0    233190 	   addresses 
   TABLE DATA           �   COPY public.addresses (id, created_at, updated_at, deleted_at, user_id, contact_name, phone, city, address1, address2) FROM stdin;
    public          postgres    false    250   ��      �          0    233324    articles 
   TABLE DATA           �   COPY public.articles (id, created_at, updated_at, deleted_at, author_id, title, content, version_name, version_priority, scheduled_start_at, scheduled_end_at, scheduled_event_id, publish_ready) FROM stdin;
    public          postgres    false    271   ��      Z          0    233026    asset_managers 
   TABLE DATA           V   COPY public.asset_managers (id, created_at, updated_at, deleted_at, file) FROM stdin;
    public          postgres    false    223   ՛      W          0    233007    auth_identities 
   TABLE DATA           �   COPY public.auth_identities (id, created_at, updated_at, deleted_at, provider, uid, encrypted_password, user_id, confirmed_at, sign_logs) FROM stdin;
    public          postgres    false    220   �      o          0    233154 
   categories 
   TABLE DATA           �   COPY public.categories (id, created_at, updated_at, deleted_at, language_code, "position", name, code, category_id) FROM stdin;
    public          postgres    false    244   �      q          0    233166    collections 
   TABLE DATA           b   COPY public.collections (id, created_at, updated_at, deleted_at, name, language_code) FROM stdin;
    public          postgres    false    246   ,�      e          0    233094    color_variation_images 
   TABLE DATA           s   COPY public.color_variation_images (id, created_at, updated_at, deleted_at, color_variation_id, image) FROM stdin;
    public          postgres    false    234   I�      c          0    233082    color_variations 
   TABLE DATA           �   COPY public.color_variations (id, created_at, updated_at, deleted_at, product_id, color_id, color_code, images, version_name) FROM stdin;
    public          postgres    false    232   f�      i          0    233115    colors 
   TABLE DATA           �   COPY public.colors (id, created_at, updated_at, deleted_at, language_code, "position", name, code, version_name, version_priority, scheduled_start_at, scheduled_end_at, scheduled_event_id, publish_ready) FROM stdin;
    public          postgres    false    238   ��      {          0    233226    delivery_methods 
   TABLE DATA           _   COPY public.delivery_methods (id, created_at, updated_at, deleted_at, name, price) FROM stdin;
    public          postgres    false    256   ��      m          0    233142 	   materials 
   TABLE DATA           f   COPY public.materials (id, created_at, updated_at, deleted_at, language_code, name, code) FROM stdin;
    public          postgres    false    242   ��      �          0    233262    media_libraries 
   TABLE DATA           m   COPY public.media_libraries (title, id, created_at, updated_at, deleted_at, selected_type, file) FROM stdin;
    public          postgres    false    262   ڜ      �          0    233337    my_seo_settings 
   TABLE DATA           z   COPY public.my_seo_settings (name, setting, is_global_seo, created_at, updated_at, deleted_at, language_code) FROM stdin;
    public          postgres    false    272   ��      y          0    233214    order_items 
   TABLE DATA           �   COPY public.order_items (id, created_at, updated_at, deleted_at, order_id, size_variation_id, quantity, price, discount_rate, state) FROM stdin;
    public          postgres    false    254   �      w          0    233202    orders 
   TABLE DATA           �  COPY public.orders (id, created_at, updated_at, deleted_at, user_id, payment_amount, payment_total, abandoned_reason, discount_value, delivery_method_id, payment_method, tracking_number, shipped_at, returned_at, cancelled_at, shipping_address_id, billing_address_id, amazon_address_access_token, amazon_order_reference_id, amazon_authorization_id, amazon_capture_id, amazon_refund_id, payment_log, state) FROM stdin;
    public          postgres    false    252   1�      �          0    233309    pages 
   TABLE DATA           �   COPY public.pages (id, created_at, updated_at, deleted_at, title, title_with_slug, containers, version_name, version_priority, scheduled_start_at, scheduled_end_at, scheduled_event_id, publish_ready) FROM stdin;
    public          postgres    false    269   N�      [          0    233036    product_collections 
   TABLE DATA           �   COPY public.product_collections (product_id, product_language_code, product_version_name, collection_id, collection_language_code) FROM stdin;
    public          postgres    false    224   k�      a          0    233070    product_images 
   TABLE DATA           �   COPY public.product_images (id, created_at, updated_at, deleted_at, title, color_id, category_id, selected_type, file) FROM stdin;
    public          postgres    false    230   ��      _          0    233058    product_variations 
   TABLE DATA           �   COPY public.product_variations (id, created_at, updated_at, deleted_at, product_id, color_id, size_id, material_id, sku, receipt_name, featured, price, selling_price, available_quantity, images) FROM stdin;
    public          postgres    false    228   ��      ]          0    233043    products 
   TABLE DATA           i  COPY public.products (id, created_at, updated_at, deleted_at, language_code, "position", name, name_with_slug, featured, code, category_id, made_country, gender, main_image, price, description, color_variations_sorter, product_properties, seo, version_name, version_priority, scheduled_start_at, scheduled_end_at, scheduled_event_id, publish_ready) FROM stdin;
    public          postgres    false    226         �          0    233286    qor_activities 
   TABLE DATA           �   COPY public.qor_activities (id, created_at, updated_at, deleted_at, action, content, note, type, resource_type, resource_id, creator_name, created_by, updated_by) FROM stdin;
    public          postgres    false    266   ߝ      �          0    233372    qor_admin_settings 
   TABLE DATA           s   COPY public.qor_admin_settings (id, created_at, updated_at, deleted_at, key, resource, user_id, value) FROM stdin;
    public          postgres    false    278   ��      �          0    233360    qor_banner_editor_settings 
   TABLE DATA           i   COPY public.qor_banner_editor_settings (id, created_at, updated_at, deleted_at, kind, value) FROM stdin;
    public          postgres    false    276   �      �          0    233348    qor_help_entries 
   TABLE DATA           k   COPY public.qor_help_entries (id, created_at, updated_at, deleted_at, title, categories, body) FROM stdin;
    public          postgres    false    274   6�      �          0    233408    qor_jobs 
   TABLE DATA           �   COPY public.qor_jobs (id, created_at, updated_at, deleted_at, status, progress, progress_text, log, results_table, created_by, updated_by, kind, value) FROM stdin;
    public          postgres    false    284   S�      �          0    233396    qor_notifications 
   TABLE DATA           �   COPY public.qor_notifications (id, created_at, updated_at, deleted_at, "from", "to", title, body, message_type, resolved_at) FROM stdin;
    public          postgres    false    282   p�      �          0    233296    qor_widget_settings 
   TABLE DATA           �   COPY public.qor_widget_settings (name, scope, source_type, source_id, description, shared, widget_type, group_name, template, kind, value, created_at, updated_at, language_code) FROM stdin;
    public          postgres    false    267   ��      �          0    233384    scheduled_events 
   TABLE DATA           ~   COPY public.scheduled_events (id, created_at, updated_at, deleted_at, name, scheduled_start_at, scheduled_end_at) FROM stdin;
    public          postgres    false    280   ��                0    233250    settings 
   TABLE DATA           �   COPY public.settings (id, created_at, updated_at, deleted_at, shipping_fee, gift_wrapping_fee, cod_fee, tax_rate, address, city, region, country, zip, latitude, longitude, language_code) FROM stdin;
    public          postgres    false    260   Ǟ      g          0    233106    size_variations 
   TABLE DATA           �   COPY public.size_variations (id, created_at, updated_at, deleted_at, color_variation_id, size_id, available_quantity, version_name) FROM stdin;
    public          postgres    false    236   �      k          0    233130    sizes 
   TABLE DATA           n   COPY public.sizes (id, created_at, updated_at, deleted_at, language_code, "position", name, code) FROM stdin;
    public          postgres    false    240   �      �          0    233274    state_change_logs 
   TABLE DATA           �   COPY public.state_change_logs (id, created_at, updated_at, deleted_at, refer_table, refer_id, "from", "to", note, created_by, updated_by) FROM stdin;
    public          postgres    false    264   �      }          0    233238    stores 
   TABLE DATA           �   COPY public.stores (id, created_at, updated_at, deleted_at, store_name, owner, phone, email, address, city, region, country, zip, latitude, longitude, "position") FROM stdin;
    public          postgres    false    258   ;�      C          0    232034    test 
   TABLE DATA           (   COPY public.test (tid, val) FROM stdin;
    public          postgres    false    199   X�      D          0    232685    test2 
   TABLE DATA           '   COPY public.test2 (t1, t2) FROM stdin;
    public          postgres    false    200   ��      X          0    233017    translations 
   TABLE DATA           :   COPY public.translations (locale, key, value) FROM stdin;
    public          postgres    false    221   ��      s          0    233178    users 
   TABLE DATA           &  COPY public.users (id, created_at, updated_at, deleted_at, email, password, name, gender, role, birthday, balance, default_billing_address, default_shipping_address, avatar, confirm_token, confirmed, recover_token, recover_token_expiry, accept_private, accept_license, accept_news) FROM stdin;
    public          postgres    false    248   ��      �           0    0    departments_dep_index_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('admin.departments_dep_index_seq', 4, true);
          admin          postgres    false    201            �           0    0    funcblocks_fb_index_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('admin.funcblocks_fb_index_seq', 3, true);
          admin          postgres    false    212            �           0    0    resources_res_index_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('admin.resources_res_index_seq', 28, true);
          admin          postgres    false    210            �           0    0    resourcetypes_rtp_index_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('admin.resourcetypes_rtp_index_seq', 7, true);
          admin          postgres    false    208            �           0    0    roles_role_index_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('admin.roles_role_index_seq', 3, true);
          admin          postgres    false    205            �           0    0    users_user_index_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('admin.users_user_index_seq', 53, true);
          admin          postgres    false    203            �           0    0    usersessions_uss_index_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('admin.usersessions_uss_index_seq', 1967, true);
          admin          postgres    false    216            �           0    0    addresses_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.addresses_id_seq', 1, false);
          public          postgres    false    249            �           0    0    articles_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.articles_id_seq', 1, false);
          public          postgres    false    270            �           0    0    asset_managers_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.asset_managers_id_seq', 1, false);
          public          postgres    false    222            �           0    0    auth_identities_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.auth_identities_id_seq', 1, false);
          public          postgres    false    219            �           0    0    categories_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.categories_id_seq', 1, false);
          public          postgres    false    243            �           0    0    collections_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.collections_id_seq', 1, false);
          public          postgres    false    245                        0    0    color_variation_images_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.color_variation_images_id_seq', 1, false);
          public          postgres    false    233                       0    0    color_variations_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.color_variations_id_seq', 1, false);
          public          postgres    false    231                       0    0    colors_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.colors_id_seq', 1, false);
          public          postgres    false    237                       0    0    delivery_methods_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.delivery_methods_id_seq', 1, false);
          public          postgres    false    255                       0    0    materials_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.materials_id_seq', 1, false);
          public          postgres    false    241                       0    0    media_libraries_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.media_libraries_id_seq', 1, false);
          public          postgres    false    261                       0    0    order_items_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.order_items_id_seq', 1, false);
          public          postgres    false    253                       0    0    orders_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.orders_id_seq', 1, false);
          public          postgres    false    251                       0    0    pages_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.pages_id_seq', 1, false);
          public          postgres    false    268            	           0    0    product_images_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.product_images_id_seq', 1, false);
          public          postgres    false    229            
           0    0    product_variations_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.product_variations_id_seq', 1, false);
          public          postgres    false    227                       0    0    products_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.products_id_seq', 1, false);
          public          postgres    false    225                       0    0    qor_activities_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.qor_activities_id_seq', 1, false);
          public          postgres    false    265                       0    0    qor_admin_settings_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.qor_admin_settings_id_seq', 1, false);
          public          postgres    false    277                       0    0 !   qor_banner_editor_settings_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.qor_banner_editor_settings_id_seq', 1, false);
          public          postgres    false    275                       0    0    qor_help_entries_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.qor_help_entries_id_seq', 1, false);
          public          postgres    false    273                       0    0    qor_jobs_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.qor_jobs_id_seq', 1, false);
          public          postgres    false    283                       0    0    qor_notifications_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.qor_notifications_id_seq', 1, false);
          public          postgres    false    281                       0    0    scheduled_events_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.scheduled_events_id_seq', 1, false);
          public          postgres    false    279                       0    0    settings_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.settings_id_seq', 1, false);
          public          postgres    false    259                       0    0    size_variations_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.size_variations_id_seq', 1, false);
          public          postgres    false    235                       0    0    sizes_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.sizes_id_seq', 1, false);
          public          postgres    false    239                       0    0    state_change_logs_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.state_change_logs_id_seq', 1, false);
          public          postgres    false    263                       0    0    stores_id_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.stores_id_seq', 1, false);
          public          postgres    false    257                       0    0    test_tid_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.test_tid_seq', 2, true);
          public          postgres    false    198                       0    0    users_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.users_id_seq', 1, false);
          public          postgres    false    247            .           2606    232706    departments dep_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY admin.departments
    ADD CONSTRAINT dep_pkey PRIMARY KEY (dep_index);
 =   ALTER TABLE ONLY admin.departments DROP CONSTRAINT dep_pkey;
       admin            postgres    false    202            B           2606    232804    funcblocks fb_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY admin.funcblocks
    ADD CONSTRAINT fb_pkey PRIMARY KEY (fb_index);
 ;   ALTER TABLE ONLY admin.funcblocks DROP CONSTRAINT fb_pkey;
       admin            postgres    false    213            H           2606    232826    funcblockresources fbres_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY admin.funcblockresources
    ADD CONSTRAINT fbres_pkey PRIMARY KEY (fb_index, res_index);
 F   ALTER TABLE ONLY admin.funcblockresources DROP CONSTRAINT fbres_pkey;
       admin            postgres    false    215    215            F           2606    232811    funcblockroles fbrole_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY admin.funcblockroles
    ADD CONSTRAINT fbrole_pkey PRIMARY KEY (fb_index, role_index);
 C   ALTER TABLE ONLY admin.funcblockroles DROP CONSTRAINT fbrole_pkey;
       admin            postgres    false    214    214            D           2606    232806 %   funcblocks funcblocks_fb_fullname_key 
   CONSTRAINT     f   ALTER TABLE ONLY admin.funcblocks
    ADD CONSTRAINT funcblocks_fb_fullname_key UNIQUE (fb_fullname);
 N   ALTER TABLE ONLY admin.funcblocks DROP CONSTRAINT funcblocks_fb_fullname_key;
       admin            postgres    false    213            >           2606    232781    resources res_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT res_pkey PRIMARY KEY (res_index);
 ;   ALTER TABLE ONLY admin.resources DROP CONSTRAINT res_pkey;
       admin            postgres    false    211            @           2606    232783 $   resources resources_res_fullname_key 
   CONSTRAINT     f   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT resources_res_fullname_key UNIQUE (res_fullname);
 M   ALTER TABLE ONLY admin.resources DROP CONSTRAINT resources_res_fullname_key;
       admin            postgres    false    211            :           2606    232770 ,   resourcetypes resourcetypes_rtp_fullname_key 
   CONSTRAINT     n   ALTER TABLE ONLY admin.resourcetypes
    ADD CONSTRAINT resourcetypes_rtp_fullname_key UNIQUE (rtp_fullname);
 U   ALTER TABLE ONLY admin.resourcetypes DROP CONSTRAINT resourcetypes_rtp_fullname_key;
       admin            postgres    false    209            4           2606    232740    roles role_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY admin.roles
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_index);
 8   ALTER TABLE ONLY admin.roles DROP CONSTRAINT role_pkey;
       admin            postgres    false    206            6           2606    232742    roles roles_role_fullname_key 
   CONSTRAINT     `   ALTER TABLE ONLY admin.roles
    ADD CONSTRAINT roles_role_fullname_key UNIQUE (role_fullname);
 F   ALTER TABLE ONLY admin.roles DROP CONSTRAINT roles_role_fullname_key;
       admin            postgres    false    206            <           2606    232768    resourcetypes rtp_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY admin.resourcetypes
    ADD CONSTRAINT rtp_pkey PRIMARY KEY (rtp_index);
 ?   ALTER TABLE ONLY admin.resourcetypes DROP CONSTRAINT rtp_pkey;
       admin            postgres    false    209            0           2606    232722    users user_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY admin.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (user_index);
 8   ALTER TABLE ONLY admin.users DROP CONSTRAINT user_pkey;
       admin            postgres    false    204            8           2606    232747    userroles userrole_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY admin.userroles
    ADD CONSTRAINT userrole_pkey PRIMARY KEY (user_index, role_index);
 @   ALTER TABLE ONLY admin.userroles DROP CONSTRAINT userrole_pkey;
       admin            postgres    false    207    207            2           2606    232724    users users_user_login_key 
   CONSTRAINT     Z   ALTER TABLE ONLY admin.users
    ADD CONSTRAINT users_user_login_key UNIQUE (user_login);
 C   ALTER TABLE ONLY admin.users DROP CONSTRAINT users_user_login_key;
       admin            postgres    false    204            J           2606    232847    usersessions uss_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY admin.usersessions
    ADD CONSTRAINT uss_pkey PRIMARY KEY (uss_index);
 >   ALTER TABLE ONLY admin.usersessions DROP CONSTRAINT uss_pkey;
       admin            postgres    false    217                       2606    233198    addresses addresses_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.addresses DROP CONSTRAINT addresses_pkey;
       public            postgres    false    250            �           2606    233332    articles articles_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id, version_name);
 @   ALTER TABLE ONLY public.articles DROP CONSTRAINT articles_pkey;
       public            postgres    false    271    271            P           2606    233034 "   asset_managers asset_managers_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.asset_managers
    ADD CONSTRAINT asset_managers_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.asset_managers DROP CONSTRAINT asset_managers_pkey;
       public            postgres    false    223            L           2606    233015 $   auth_identities auth_identities_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.auth_identities
    ADD CONSTRAINT auth_identities_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.auth_identities DROP CONSTRAINT auth_identities_pkey;
       public            postgres    false    220            v           2606    233162    categories categories_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id, language_code);
 D   ALTER TABLE ONLY public.categories DROP CONSTRAINT categories_pkey;
       public            postgres    false    244    244            y           2606    233174    collections collections_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id, language_code);
 F   ALTER TABLE ONLY public.collections DROP CONSTRAINT collections_pkey;
       public            postgres    false    246    246            d           2606    233102 2   color_variation_images color_variation_images_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.color_variation_images
    ADD CONSTRAINT color_variation_images_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.color_variation_images DROP CONSTRAINT color_variation_images_pkey;
       public            postgres    false    234            a           2606    233090 &   color_variations color_variations_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.color_variations
    ADD CONSTRAINT color_variations_pkey PRIMARY KEY (id, version_name);
 P   ALTER TABLE ONLY public.color_variations DROP CONSTRAINT color_variations_pkey;
       public            postgres    false    232    232            j           2606    233123    colors colors_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY public.colors
    ADD CONSTRAINT colors_pkey PRIMARY KEY (id, language_code, version_name);
 <   ALTER TABLE ONLY public.colors DROP CONSTRAINT colors_pkey;
       public            postgres    false    238    238    238            �           2606    233234 &   delivery_methods delivery_methods_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.delivery_methods
    ADD CONSTRAINT delivery_methods_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.delivery_methods DROP CONSTRAINT delivery_methods_pkey;
       public            postgres    false    256            t           2606    233150    materials materials_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_pkey PRIMARY KEY (id, language_code);
 B   ALTER TABLE ONLY public.materials DROP CONSTRAINT materials_pkey;
       public            postgres    false    242    242            �           2606    233270 $   media_libraries media_libraries_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.media_libraries
    ADD CONSTRAINT media_libraries_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.media_libraries DROP CONSTRAINT media_libraries_pkey;
       public            postgres    false    262            �           2606    233344 $   my_seo_settings my_seo_settings_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.my_seo_settings
    ADD CONSTRAINT my_seo_settings_pkey PRIMARY KEY (name, language_code);
 N   ALTER TABLE ONLY public.my_seo_settings DROP CONSTRAINT my_seo_settings_pkey;
       public            postgres    false    272    272            �           2606    233222    order_items order_items_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.order_items DROP CONSTRAINT order_items_pkey;
       public            postgres    false    254            �           2606    233210    orders orders_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public            postgres    false    252            �           2606    233317    pages pages_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (id, version_name);
 :   ALTER TABLE ONLY public.pages DROP CONSTRAINT pages_pkey;
       public            postgres    false    269    269            S           2606    233040 ,   product_collections product_collections_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.product_collections
    ADD CONSTRAINT product_collections_pkey PRIMARY KEY (product_id, product_language_code, product_version_name, collection_id, collection_language_code);
 V   ALTER TABLE ONLY public.product_collections DROP CONSTRAINT product_collections_pkey;
       public            postgres    false    224    224    224    224    224            _           2606    233078 "   product_images product_images_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.product_images DROP CONSTRAINT product_images_pkey;
       public            postgres    false    230            \           2606    233066 *   product_variations product_variations_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.product_variations
    ADD CONSTRAINT product_variations_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.product_variations DROP CONSTRAINT product_variations_pkey;
       public            postgres    false    228            Y           2606    233051    products products_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id, language_code, version_name);
 @   ALTER TABLE ONLY public.products DROP CONSTRAINT products_pkey;
       public            postgres    false    226    226    226            �           2606    233294 "   qor_activities qor_activities_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.qor_activities
    ADD CONSTRAINT qor_activities_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.qor_activities DROP CONSTRAINT qor_activities_pkey;
       public            postgres    false    266            �           2606    233380 *   qor_admin_settings qor_admin_settings_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.qor_admin_settings
    ADD CONSTRAINT qor_admin_settings_pkey PRIMARY KEY (id);
 T   ALTER TABLE ONLY public.qor_admin_settings DROP CONSTRAINT qor_admin_settings_pkey;
       public            postgres    false    278            �           2606    233368 :   qor_banner_editor_settings qor_banner_editor_settings_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.qor_banner_editor_settings
    ADD CONSTRAINT qor_banner_editor_settings_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.qor_banner_editor_settings DROP CONSTRAINT qor_banner_editor_settings_pkey;
       public            postgres    false    276            �           2606    233356 &   qor_help_entries qor_help_entries_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.qor_help_entries
    ADD CONSTRAINT qor_help_entries_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.qor_help_entries DROP CONSTRAINT qor_help_entries_pkey;
       public            postgres    false    274            �           2606    233417    qor_jobs qor_jobs_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.qor_jobs
    ADD CONSTRAINT qor_jobs_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.qor_jobs DROP CONSTRAINT qor_jobs_pkey;
       public            postgres    false    284            �           2606    233404 (   qor_notifications qor_notifications_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.qor_notifications
    ADD CONSTRAINT qor_notifications_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.qor_notifications DROP CONSTRAINT qor_notifications_pkey;
       public            postgres    false    282            �           2606    233306 ,   qor_widget_settings qor_widget_settings_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.qor_widget_settings
    ADD CONSTRAINT qor_widget_settings_pkey PRIMARY KEY (name, scope, source_type, source_id, language_code);
 V   ALTER TABLE ONLY public.qor_widget_settings DROP CONSTRAINT qor_widget_settings_pkey;
       public            postgres    false    267    267    267    267    267            �           2606    233392 &   scheduled_events scheduled_events_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.scheduled_events
    ADD CONSTRAINT scheduled_events_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.scheduled_events DROP CONSTRAINT scheduled_events_pkey;
       public            postgres    false    280            �           2606    233258    settings settings_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id, language_code);
 @   ALTER TABLE ONLY public.settings DROP CONSTRAINT settings_pkey;
       public            postgres    false    260    260            h           2606    233111 $   size_variations size_variations_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.size_variations
    ADD CONSTRAINT size_variations_pkey PRIMARY KEY (id, version_name);
 N   ALTER TABLE ONLY public.size_variations DROP CONSTRAINT size_variations_pkey;
       public            postgres    false    236    236            q           2606    233138    sizes sizes_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.sizes
    ADD CONSTRAINT sizes_pkey PRIMARY KEY (id, language_code);
 :   ALTER TABLE ONLY public.sizes DROP CONSTRAINT sizes_pkey;
       public            postgres    false    240    240            �           2606    233282 (   state_change_logs state_change_logs_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.state_change_logs
    ADD CONSTRAINT state_change_logs_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.state_change_logs DROP CONSTRAINT state_change_logs_pkey;
       public            postgres    false    264            �           2606    233246    stores stores_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.stores DROP CONSTRAINT stores_pkey;
       public            postgres    false    258            *           2606    232692    test2 t2pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.test2
    ADD CONSTRAINT t2pkey PRIMARY KEY (t1);
 6   ALTER TABLE ONLY public.test2 DROP CONSTRAINT t2pkey;
       public            postgres    false    200            ,           2606    232694    test2 test2_t2_key 
   CONSTRAINT     K   ALTER TABLE ONLY public.test2
    ADD CONSTRAINT test2_t2_key UNIQUE (t2);
 <   ALTER TABLE ONLY public.test2 DROP CONSTRAINT test2_t2_key;
       public            postgres    false    200            (           2606    232042    test test_pkey 
   CONSTRAINT     M   ALTER TABLE ONLY public.test
    ADD CONSTRAINT test_pkey PRIMARY KEY (tid);
 8   ALTER TABLE ONLY public.test DROP CONSTRAINT test_pkey;
       public            postgres    false    199            }           2606    233186    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public            postgres    false    248            �           1259    233199    idx_addresses_deleted_at    INDEX     T   CREATE INDEX idx_addresses_deleted_at ON public.addresses USING btree (deleted_at);
 ,   DROP INDEX public.idx_addresses_deleted_at;
       public            postgres    false    250            �           1259    233333    idx_articles_deleted_at    INDEX     R   CREATE INDEX idx_articles_deleted_at ON public.articles USING btree (deleted_at);
 +   DROP INDEX public.idx_articles_deleted_at;
       public            postgres    false    271            �           1259    233336    idx_articles_scheduled_end_at    INDEX     ^   CREATE INDEX idx_articles_scheduled_end_at ON public.articles USING btree (scheduled_end_at);
 1   DROP INDEX public.idx_articles_scheduled_end_at;
       public            postgres    false    271            �           1259    233335    idx_articles_scheduled_start_at    INDEX     b   CREATE INDEX idx_articles_scheduled_start_at ON public.articles USING btree (scheduled_start_at);
 3   DROP INDEX public.idx_articles_scheduled_start_at;
       public            postgres    false    271            �           1259    233334    idx_articles_version_priority    INDEX     ^   CREATE INDEX idx_articles_version_priority ON public.articles USING btree (version_priority);
 1   DROP INDEX public.idx_articles_version_priority;
       public            postgres    false    271            Q           1259    233035    idx_asset_managers_deleted_at    INDEX     ^   CREATE INDEX idx_asset_managers_deleted_at ON public.asset_managers USING btree (deleted_at);
 1   DROP INDEX public.idx_asset_managers_deleted_at;
       public            postgres    false    223            M           1259    233016    idx_auth_identities_deleted_at    INDEX     `   CREATE INDEX idx_auth_identities_deleted_at ON public.auth_identities USING btree (deleted_at);
 2   DROP INDEX public.idx_auth_identities_deleted_at;
       public            postgres    false    220            w           1259    233163    idx_categories_deleted_at    INDEX     V   CREATE INDEX idx_categories_deleted_at ON public.categories USING btree (deleted_at);
 -   DROP INDEX public.idx_categories_deleted_at;
       public            postgres    false    244            z           1259    233175    idx_collections_deleted_at    INDEX     X   CREATE INDEX idx_collections_deleted_at ON public.collections USING btree (deleted_at);
 .   DROP INDEX public.idx_collections_deleted_at;
       public            postgres    false    246            e           1259    233103 %   idx_color_variation_images_deleted_at    INDEX     n   CREATE INDEX idx_color_variation_images_deleted_at ON public.color_variation_images USING btree (deleted_at);
 9   DROP INDEX public.idx_color_variation_images_deleted_at;
       public            postgres    false    234            b           1259    233091    idx_color_variations_deleted_at    INDEX     b   CREATE INDEX idx_color_variations_deleted_at ON public.color_variations USING btree (deleted_at);
 3   DROP INDEX public.idx_color_variations_deleted_at;
       public            postgres    false    232            k           1259    233127    idx_colors_deleted_at    INDEX     N   CREATE INDEX idx_colors_deleted_at ON public.colors USING btree (deleted_at);
 )   DROP INDEX public.idx_colors_deleted_at;
       public            postgres    false    238            l           1259    233126    idx_colors_scheduled_end_at    INDEX     Z   CREATE INDEX idx_colors_scheduled_end_at ON public.colors USING btree (scheduled_end_at);
 /   DROP INDEX public.idx_colors_scheduled_end_at;
       public            postgres    false    238            m           1259    233125    idx_colors_scheduled_start_at    INDEX     ^   CREATE INDEX idx_colors_scheduled_start_at ON public.colors USING btree (scheduled_start_at);
 1   DROP INDEX public.idx_colors_scheduled_start_at;
       public            postgres    false    238            n           1259    233124    idx_colors_version_priority    INDEX     Z   CREATE INDEX idx_colors_version_priority ON public.colors USING btree (version_priority);
 /   DROP INDEX public.idx_colors_version_priority;
       public            postgres    false    238            �           1259    233235    idx_delivery_methods_deleted_at    INDEX     b   CREATE INDEX idx_delivery_methods_deleted_at ON public.delivery_methods USING btree (deleted_at);
 3   DROP INDEX public.idx_delivery_methods_deleted_at;
       public            postgres    false    256            r           1259    233151    idx_materials_deleted_at    INDEX     T   CREATE INDEX idx_materials_deleted_at ON public.materials USING btree (deleted_at);
 ,   DROP INDEX public.idx_materials_deleted_at;
       public            postgres    false    242            �           1259    233271    idx_media_libraries_deleted_at    INDEX     `   CREATE INDEX idx_media_libraries_deleted_at ON public.media_libraries USING btree (deleted_at);
 2   DROP INDEX public.idx_media_libraries_deleted_at;
       public            postgres    false    262            �           1259    233345    idx_my_seo_settings_deleted_at    INDEX     `   CREATE INDEX idx_my_seo_settings_deleted_at ON public.my_seo_settings USING btree (deleted_at);
 2   DROP INDEX public.idx_my_seo_settings_deleted_at;
       public            postgres    false    272            �           1259    233223    idx_order_items_deleted_at    INDEX     X   CREATE INDEX idx_order_items_deleted_at ON public.order_items USING btree (deleted_at);
 .   DROP INDEX public.idx_order_items_deleted_at;
       public            postgres    false    254            �           1259    233211    idx_orders_deleted_at    INDEX     N   CREATE INDEX idx_orders_deleted_at ON public.orders USING btree (deleted_at);
 )   DROP INDEX public.idx_orders_deleted_at;
       public            postgres    false    252            �           1259    233318    idx_pages_deleted_at    INDEX     L   CREATE INDEX idx_pages_deleted_at ON public.pages USING btree (deleted_at);
 (   DROP INDEX public.idx_pages_deleted_at;
       public            postgres    false    269            �           1259    233321    idx_pages_scheduled_end_at    INDEX     X   CREATE INDEX idx_pages_scheduled_end_at ON public.pages USING btree (scheduled_end_at);
 .   DROP INDEX public.idx_pages_scheduled_end_at;
       public            postgres    false    269            �           1259    233320    idx_pages_scheduled_start_at    INDEX     \   CREATE INDEX idx_pages_scheduled_start_at ON public.pages USING btree (scheduled_start_at);
 0   DROP INDEX public.idx_pages_scheduled_start_at;
       public            postgres    false    269            �           1259    233319    idx_pages_version_priority    INDEX     X   CREATE INDEX idx_pages_version_priority ON public.pages USING btree (version_priority);
 .   DROP INDEX public.idx_pages_version_priority;
       public            postgres    false    269            ]           1259    233079    idx_product_images_deleted_at    INDEX     ^   CREATE INDEX idx_product_images_deleted_at ON public.product_images USING btree (deleted_at);
 1   DROP INDEX public.idx_product_images_deleted_at;
       public            postgres    false    230            Z           1259    233067 !   idx_product_variations_deleted_at    INDEX     f   CREATE INDEX idx_product_variations_deleted_at ON public.product_variations USING btree (deleted_at);
 5   DROP INDEX public.idx_product_variations_deleted_at;
       public            postgres    false    228            T           1259    233054    idx_products_deleted_at    INDEX     R   CREATE INDEX idx_products_deleted_at ON public.products USING btree (deleted_at);
 +   DROP INDEX public.idx_products_deleted_at;
       public            postgres    false    226            U           1259    233053    idx_products_scheduled_end_at    INDEX     ^   CREATE INDEX idx_products_scheduled_end_at ON public.products USING btree (scheduled_end_at);
 1   DROP INDEX public.idx_products_scheduled_end_at;
       public            postgres    false    226            V           1259    233052    idx_products_scheduled_start_at    INDEX     b   CREATE INDEX idx_products_scheduled_start_at ON public.products USING btree (scheduled_start_at);
 3   DROP INDEX public.idx_products_scheduled_start_at;
       public            postgres    false    226            W           1259    233055    idx_products_version_priority    INDEX     ^   CREATE INDEX idx_products_version_priority ON public.products USING btree (version_priority);
 1   DROP INDEX public.idx_products_version_priority;
       public            postgres    false    226            �           1259    233295    idx_qor_activities_deleted_at    INDEX     ^   CREATE INDEX idx_qor_activities_deleted_at ON public.qor_activities USING btree (deleted_at);
 1   DROP INDEX public.idx_qor_activities_deleted_at;
       public            postgres    false    266            �           1259    233381 !   idx_qor_admin_settings_deleted_at    INDEX     f   CREATE INDEX idx_qor_admin_settings_deleted_at ON public.qor_admin_settings USING btree (deleted_at);
 5   DROP INDEX public.idx_qor_admin_settings_deleted_at;
       public            postgres    false    278            �           1259    233369 )   idx_qor_banner_editor_settings_deleted_at    INDEX     v   CREATE INDEX idx_qor_banner_editor_settings_deleted_at ON public.qor_banner_editor_settings USING btree (deleted_at);
 =   DROP INDEX public.idx_qor_banner_editor_settings_deleted_at;
       public            postgres    false    276            �           1259    233357    idx_qor_help_entries_deleted_at    INDEX     b   CREATE INDEX idx_qor_help_entries_deleted_at ON public.qor_help_entries USING btree (deleted_at);
 3   DROP INDEX public.idx_qor_help_entries_deleted_at;
       public            postgres    false    274            �           1259    233418    idx_qor_jobs_deleted_at    INDEX     R   CREATE INDEX idx_qor_jobs_deleted_at ON public.qor_jobs USING btree (deleted_at);
 +   DROP INDEX public.idx_qor_jobs_deleted_at;
       public            postgres    false    284            �           1259    233405     idx_qor_notifications_deleted_at    INDEX     d   CREATE INDEX idx_qor_notifications_deleted_at ON public.qor_notifications USING btree (deleted_at);
 4   DROP INDEX public.idx_qor_notifications_deleted_at;
       public            postgres    false    282            �           1259    233393    idx_scheduled_events_deleted_at    INDEX     b   CREATE INDEX idx_scheduled_events_deleted_at ON public.scheduled_events USING btree (deleted_at);
 3   DROP INDEX public.idx_scheduled_events_deleted_at;
       public            postgres    false    280            �           1259    233259    idx_settings_deleted_at    INDEX     R   CREATE INDEX idx_settings_deleted_at ON public.settings USING btree (deleted_at);
 +   DROP INDEX public.idx_settings_deleted_at;
       public            postgres    false    260            f           1259    233112    idx_size_variations_deleted_at    INDEX     `   CREATE INDEX idx_size_variations_deleted_at ON public.size_variations USING btree (deleted_at);
 2   DROP INDEX public.idx_size_variations_deleted_at;
       public            postgres    false    236            o           1259    233139    idx_sizes_deleted_at    INDEX     L   CREATE INDEX idx_sizes_deleted_at ON public.sizes USING btree (deleted_at);
 (   DROP INDEX public.idx_sizes_deleted_at;
       public            postgres    false    240            �           1259    233283     idx_state_change_logs_deleted_at    INDEX     d   CREATE INDEX idx_state_change_logs_deleted_at ON public.state_change_logs USING btree (deleted_at);
 4   DROP INDEX public.idx_state_change_logs_deleted_at;
       public            postgres    false    264            �           1259    233247    idx_stores_deleted_at    INDEX     N   CREATE INDEX idx_stores_deleted_at ON public.stores USING btree (deleted_at);
 )   DROP INDEX public.idx_stores_deleted_at;
       public            postgres    false    258            N           1259    233023     idx_translations_key_with_locale    INDEX     g   CREATE UNIQUE INDEX idx_translations_key_with_locale ON public.translations USING btree (locale, key);
 4   DROP INDEX public.idx_translations_key_with_locale;
       public            postgres    false    221    221            {           1259    233187    idx_users_deleted_at    INDEX     L   CREATE INDEX idx_users_deleted_at ON public.users USING btree (deleted_at);
 (   DROP INDEX public.idx_users_deleted_at;
       public            postgres    false    248            �           2606    232707    departments dep_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.departments
    ADD CONSTRAINT dep_fkey FOREIGN KEY (dep_dep_index) REFERENCES admin.departments(dep_index);
 =   ALTER TABLE ONLY admin.departments DROP CONSTRAINT dep_fkey;
       admin          postgres    false    202    3118    202            �           2606    232827    funcblockresources fbres_f_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockresources
    ADD CONSTRAINT fbres_f_fkey FOREIGN KEY (fb_index) REFERENCES admin.funcblocks(fb_index);
 H   ALTER TABLE ONLY admin.funcblockresources DROP CONSTRAINT fbres_f_fkey;
       admin          postgres    false    213    3138    215            �           2606    232832    funcblockresources fbres_r_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockresources
    ADD CONSTRAINT fbres_r_fkey FOREIGN KEY (res_index) REFERENCES admin.resources(res_index);
 H   ALTER TABLE ONLY admin.funcblockresources DROP CONSTRAINT fbres_r_fkey;
       admin          postgres    false    211    3134    215            �           2606    232812    funcblockroles fbrole_f_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockroles
    ADD CONSTRAINT fbrole_f_fkey FOREIGN KEY (fb_index) REFERENCES admin.funcblocks(fb_index);
 E   ALTER TABLE ONLY admin.funcblockroles DROP CONSTRAINT fbrole_f_fkey;
       admin          postgres    false    214    3138    213            �           2606    232817    funcblockroles fbrole_r_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.funcblockroles
    ADD CONSTRAINT fbrole_r_fkey FOREIGN KEY (role_index) REFERENCES admin.roles(role_index);
 E   ALTER TABLE ONLY admin.funcblockroles DROP CONSTRAINT fbrole_r_fkey;
       admin          postgres    false    214    206    3124            �           2606    232784    resources res_rr_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT res_rr_fkey FOREIGN KEY (res_res_index) REFERENCES admin.resources(res_index);
 >   ALTER TABLE ONLY admin.resources DROP CONSTRAINT res_rr_fkey;
       admin          postgres    false    211    3134    211            �           2606    232789    resources res_rtp_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.resources
    ADD CONSTRAINT res_rtp_fkey FOREIGN KEY (rtp_index) REFERENCES admin.resourcetypes(rtp_index);
 ?   ALTER TABLE ONLY admin.resources DROP CONSTRAINT res_rtp_fkey;
       admin          postgres    false    209    3132    211            �           2606    232725    users user_fkey    FK CONSTRAINT     {   ALTER TABLE ONLY admin.users
    ADD CONSTRAINT user_fkey FOREIGN KEY (dep_index) REFERENCES admin.departments(dep_index);
 8   ALTER TABLE ONLY admin.users DROP CONSTRAINT user_fkey;
       admin          postgres    false    204    202    3118            �           2606    232753    userroles userrole_r_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.userroles
    ADD CONSTRAINT userrole_r_fkey FOREIGN KEY (role_index) REFERENCES admin.roles(role_index);
 B   ALTER TABLE ONLY admin.userroles DROP CONSTRAINT userrole_r_fkey;
       admin          postgres    false    206    3124    207            �           2606    232748    userroles userrole_u_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY admin.userroles
    ADD CONSTRAINT userrole_u_fkey FOREIGN KEY (user_index) REFERENCES admin.users(user_index);
 B   ALTER TABLE ONLY admin.userroles DROP CONSTRAINT userrole_u_fkey;
       admin          postgres    false    204    207    3120            �           2606    232853    usersessions uss_r_fkey    FK CONSTRAINT        ALTER TABLE ONLY admin.usersessions
    ADD CONSTRAINT uss_r_fkey FOREIGN KEY (role_index) REFERENCES admin.roles(role_index);
 @   ALTER TABLE ONLY admin.usersessions DROP CONSTRAINT uss_r_fkey;
       admin          postgres    false    3124    217    206            �           2606    232848    usersessions uss_u_fkey    FK CONSTRAINT        ALTER TABLE ONLY admin.usersessions
    ADD CONSTRAINT uss_u_fkey FOREIGN KEY (user_index) REFERENCES admin.users(user_index);
 @   ALTER TABLE ONLY admin.usersessions DROP CONSTRAINT uss_u_fkey;
       admin          postgres    false    3120    204    217            F   >   x�3���I-.ц\Ɯ��%@�g�Rvj����RYbNi�R-P��$kbq��qqq $L�      S   C   x�˱� �a��%���~��s[rs?l���S�����܇��"�E(B�,}���|b      R      x�3�4�2�4b#�=... K      Q   _   x�3�LL��̋/H�K�� �
��ɩ�řy�
9�y� �$_�L!7?%�3Ə˘3)�83Y!?)+5���5 5�/'G��8��8&�1F��� ur'�      O   �  x�e��n�0���S�	��n�ä��N�����*�%���~��v� ���W����q/<8?��}G�]J�p��"�z�)F�
eTݷ���ʋ����X#���L�aH�l����`����c��m��H�HV���>S������ �Md!�\�(�H�:S����|Ԧ�����~�¿AH����p�:o�o����/F��bI�\>�Љ4��%�/�|7��v��n�u�Er�dr�F��MKG�����F�\�iQ�����_��6���|y3Ut���J�H�u<!��nT�UK��u�Զ!�W�$�co��d�C�w*Ճ6��(<G~��[+�����@�I�����ӻ�qK�
-'�5LY3B�	RY���PH` �\MHo���w�eY�,�:s      M   �   x�M���0Dg�+�E	� $`h� [��r ��U�
��$$�����g]��,7Z�)���Q+�>�i��4���x����%�-_�J��^:����	ǯG��1>���Q�ԧ��mk�i'a�"��	�b�CF�k�PJ��?�      J   +   x�3�,I-.�/-N-���WHL������2��C�p�=... ���      K   #   x�3�4�2�4�2bs 61 �H��qqq T��      H   �  x�}��n�@���c���0���9�@m��"Uf�D}�����T�������Kcִ(��j�P�%�ћƬň��aA�P��&��*P�+�"��{����3v՟X64�U]�u��E$�@��Oe���R��c#��wBT���@p�.��|r7'�1�����A�ɦ &��J"@���7��������g_yr*�4�$E;۶:���Ɩ�}�km�g���LMq,["�����cFﻸn#F�:p�]7���R�l+���Mn�8׋���I=@�U
pwfꓮ.�<J*�+�95Y|�o㬨�������ڊ��<�M��U����'��$q�o��������)*�v߾>��w�}b)�,?�g�5�&��R�^j��:��U����A���;�.��h��O���?]���F�f�?����      U      x�m�ە,7�D�5Vȁ�E��Gq-������FpI_�3�*L���T�ҿ�/i����2�n�GƏ��J�������e~Z���ӛ�K��>�5,��@��g��� �����m��$o��%mvs̗�~�?ۺ,�~�����.�}�`�#4٦K���K��l�9����&.�?��?(��n��5����׸�����6��_�z�^~��������A�h��GW��g�G�4-��}��~���?i��=L���Qt������~�؏�^}����htݫ�GF>�z4� �?�c��4��WTa�?����?�Ѻ�xtF��T�IN����%��q�F{�I/C�����qt+	^���c/�^���y|Z�f�i��?���k�k�b����bD�����OO|m��z�F$?�~z�ĥ���K�>�]������x¸�?�^�!/�㡶x���(v^���ۚF�<f���W��m����M���?Izɾ���=�_C?�lL���)fc>��9��9ܛx��c�3���1��1㧵0̌�����.|�Z��?=ޜ��'��U{�E���\���c8=������^��/��~P8m�7?3�_�	f���F�y�i1�c=q�1�Ż��-b�|�O1��rz�';rv]S�M�4�� !�;�?��QS�G"*�,�A����l�S'��#��������K0،�k���^�/��im�����1��i�pk�����="L��V�V���A��l�^���,���f�����K���K0�/dHS2ۚo������`��������M�`�n3���6��)'Vnl��_�|}Vz4n���⎐*d� ��Cv�[p3�k7:� C\{�{fCo̩�"��<�m64n�<���b����I�I��$`C�`�z�ɓ��fC#S�@�tԛ����'�Խ���j�-AZ��e��1�ĜgTE��H&[I:E��1{��	/9�'�-�6��.�c�|	p�����`��h�H�gJ���iRGFX�%H'�V��$AD1��I�z��xA��J��u�{�di�?Y@��.��^'KC0��D�&�t'K� 2���D����,A�����M4K�,-�Cb��������Ң9��On�B�xm_�;�w��*���`##V��d)��n�Z�F�>TY�_��Wk�Ϫ@^�	��#�1���K�)�a�f' �����S>~���:"����x	~�r�-�1^:߿?g>>'^ĸdF�h��z	6b�i殂�D܈yIE���� ^�H��84�u}�Hd�b�6�.]_ ���#�i���f�ޓ)PW6� ��w�wD��y}$�3f%J����;d8�S ��]��Ә��#�#�)��c|ENԺ5������
��!��tc3��j` +��A7ml��|~f�C������oc������۰C�J�l���%�-b���e�p����8����tL���#�b���o�F2�Bp���Җs��L���e�&\���ei��	�y	^��K�PМ�/;�$�7n�����	H�-���egO
䮔�w��Nz�(K��2s�?1Gva�f���@�Z�����l�cC����,��'�m��26��9�t@�*`3�`!q�z��9��!ظi&H����1#ޞp�,`C|L�HM�v$`K�
���`�:��qu�ukJ�����c�1�9T/KK�n��(����G���tUyٹ>#4��͗�o��s��^��3��$��5����:3K3�}�d;+�o�-x���s]ډ���vV���#��)}���8 �;�;;��f�\��p���Cb3+�D`8t�d��Ί@,f��H�`���X��"ʠ�m��5�4�$�(���93��nuK*/;����h�V^v��2�]��ZqY^�������#�\.S��/C�FN��BG�ⲯ ��xwic�eG`g�r(���ˎ�1�-%��*/��#Bt��ǌ(���¿�9x�D���h �j��[�r<T9ZF2��#>�Z9��|z�t=�� �S��`�b�#H��ך<T��ֈ��P1�88��%4K�hG��$B}Nҥb4��I�K�����r�?�w�i����"��{`CO����6���&����r�T�vX���{n�\R9�lı��]�ceKO�I[�&1Z���X.�d�W9�L�n�@z�MW�v+Ʉ�F�U*G;��a &�ꮤr��I�5�1R9�W`@{:y,U,&���7�!r(�Il�\�sTLl��XL�z]�iN�H*��N�Á"A S��N�g�uj�bg�(^�pcNK �T�,uD8�S�0;������n�P/��rr��T�,��	;�闡#�C�8��l/���~В�����㯳���{�ҹ��bz��3~a�u~��N�0�:�2f����	㯳D!���"�0�� c�m�\��a v�uS��Wb ��s�-�E�O���3~��)��_�P9��p���0���Y�e{l�AA��ec�j��(�� ȴκQa�%���G��;��o�P,��7��C H�#M��~��Y�c˕Aa�A�ADVg�����y<%6��M+
��RI2$�ݳc�%��)Y[��/Ʉ�8�$)b�_��.� "x�iF$!���  �d��旊��G�����L�p}����C��NI[x[���V�� ��|I:��	c1r῁��u���	 R��T9Za,v1'E����� F$j��Q�!�� 8�..-�br��z��c���d���F������dR�ꢹ�ra,vfF���K�XL2��H��^2�L�q�5hQF�IfŊ��i=X��I��I����T+�\%L��T*v�7�چ�ЫXL�Bg\bs	�F�X�w� L�b�� �&�y�b�#X��4�6H�b)����`C��T*��R*�����r�#P`���D#�r�H�ɉUz���A��0\z���ߚ�N��R�X
�Eji���ž̓X���Z��`��-�1�,&��/GY���ǼGE�R��d�ڈ��\F�b���w��+ӻԭ�����b�X��%��n��l��X؀�Q�b)����� *�:�r�)���#�Y��ms�_���~�p2����/����X���Ql]���u�Ȉ"	��*�:E���S�Ė���w�m�죕�]� �&�����]��+6�ރV�u��.Ҧ`\+�:����1�:����U�.�4P+�:�W��M�Z�� �C������8*�?�?J۴�#��� QxUS+�:���d��"���+'�1��ʿ� �I$ˑ.�7��s���~E��#Ь���,�Il�{"���f���$!�O��D+0;���k�E�U+0KA�,��h����L�>$9c-:j%f_�	r��b���&^��&M�Z����el����X+1K�d��0m-i%fzWf��(|%��j%fzWf#a��D�V`�w�j��H��,��S9��pzA+/;�cW	^v��ߖA4�������F��(��ˎ`%��ɵZy����FzA+/KP��� ��3��#8��)�i�e_��gM�
]��L� ��l����+�3tObZ�ٹ^��M"�Z�ٹ>���Ǣ:B���<AjL��ifG�5�hN5��#�	!#]z���/���tz�+0;�\���z�_ifG0�"-B%�(��#H:5���L��,�r��G>������M[i�eG �q����4��F.
Af_ADo����V`����rlU��~ׄ�'#^��J���	���-��H�h,��©;���Ǝ��S��_+ӻ���|%�Zј��b�F`�P���d���pN����N6�鄜FEc_A:���i�U4v����U�Z�X
bxwTg�N�D+;��Ȭ��StEczw|�����g�h,���D��AqEcz�'bF\&�*;�l&�m�ъƾ��d��Ҿ2z�a@���l��-~��j�\��8�cX���B�t����-����aǲR��2�!    Q�/���p�7��$�p,��Ud�����+�z�T�� ȸAP����^�/#&�Ɨ3�:x���fN�@�A���-fpΖ�A�Yc�����h�x}�L=mBSFcg�S�r^�ъ�,�^.�c3O'��MM:P��j_�h̾��=\�*�����ֱF�k�_�g�p���l��O+�o�掸A:��iecv��cΝn��*���`�Ȧ�9�l���#r�N�Z�X
[Gbr�����A.!tT0��e�'��ƙ/C{�!�)��^/C{.������(&�H��e
�l�2�hg
�����U6v��q�F�U6v����)�M��1����,��$`Kk1IǤ^�U6v9��l�DYec)P,=�����m�����Sb�c���-(V0.ϱ�������X%c�-��6���?a�2w������� �O�7na �	��#�b� ��.��H�תr��*�P����/I\Y�ƏE�9���A4�z��G���iz�J�6�4��D�I1�U����}N�qW�[
��tr�nI���� �^�����#g��4�X�n{P϶��ժV��L���o�{�r�� ����*w;�,�D�8��X�nG����7����}��vĆ����#Xؙ"�h��U�v�Oh���=��{���5&V���\N��=W�k١ &c�V���#0��`��*w���D�cqœU�vY��Xl�׳r�#����9H�g�����V��F0��Q�ЌFoG��(�y�����l�^P��m[����C(6�J���D
��F#�b���["�^���[%oG��Ϛ=�cX%o)��%A�hX%o;�v����� [:����M��a��� �XD�X�d[Z/���[`Cg�!�<�x��1`nk�v��-�?�[�y�C���f:��ܢ�*x;�, [��=~�o;��k�3� �z���v���ڸ>�
x;�B�����V��h������L���+H��ÉQ!��v���!��j�]�ʊ�f�� +��
vv��������#���}H /��jt�дlj�ei_��P,�Sli��L�6����{�%��6t�R�J�O�^�v��1�6���M�Y�eY2Plg��J?1�s�$;��s��M�6���변�Y@v�;WΡm��OQ��q�so�dg�%G��I�&'���f%��,6�Ψm�a��?'Z�Y=�C�Edg�hR3�$3��׈[DzĠm�̌�L�������=�˅�U�z�o��;os��23%T6�N���̧�V?9=�m���FVh�H�����z�n��Ư�b;�l��3���U�����F��[Z�"Nz���l�즃΃��������(\��n�u��X<�
�
v�G�J�� h�]z^}�X����`�#��!��
v��,�^�k�`�grd���a�]A�G�!?��d��O
d�`�.�e��ƭE�`�+��]tlzE���s6	K��yM�[:Cb|��E+W�����r�k4Z�Ɩ�N�K7���Y�`g�q���Y��,\e�Il�DN����ycK�J���[�xY�'zG�;�����t�7Mi�����tn�\��C�/Kg���G&�_�F�<�r�\���ei�����i�����%��t4P��_�FCb�T�b%�/C����x=���Кs��S��G^�֝վ.����eh�F��"?��24R�W�x��}�L;�w�����E��'Q�������,./C�ْ�Џ�/K{n[��^����=����x��eh��FL���ehi�z�"���*m�5��3�/C{�o-yw��eg�B?�I����l�`f���/`3[&?1��p��lf��j��fP'NW6��f�����Q63�^#�sd�l6�s
0���F���Q���!2�M�ҍ�l���IFFU�v�l?��½u��ЖE
�Мm��ei�6�4z�m�=�,�\��J	����(����F�������ӣU7�t�o@�cKxQdi*��e`��dh\�aw_�NU�d� �k(6ڲ�}��ǖl�`�\��z��=˽��#�N���`,���+��{cGpz�+*.I��1#��p�W0vY����yc_�d?�o���#H�-O����-O%�>��+�g�4>#a(�`�fn���)U0v~�s�(+K��{N>�R%c_Af?�w�{EcG�� �����Ǝ k�F$?�T4v	Y�p�xEcG��e"YZP�Ǝ ���x�*;ק�0t�!3T2�Mxr���l���3�oحɷ�vƞ��MÂ_�JƎ Mr�S��W0���s�:ɰ��,��#��c�Fd�h,ب��Q1�W4vY̵tq�S�hL�zw�O>������U��k�^�����|«ov����:}���{%c)8���1����di���>dhIX>	[ىU2&���rCќ�Vf���#�<%$�h*I�JƎ 7 ��-~��1�e
�`�=S190;��	�����<�
�ȨR��v��r��PLrۥ���c�� �
%�z�3��v)h��JG�P�+o�4����A��2��N�D�ָ��`(v�&m�:3��P�MtD��T�;�I|��7�{<�z��c��`(���1y��2�`(&�nt^M�<�`(&����q��oxY�s�ƞ�^/K��t�Q��`&&��7Dt���о�IP��3�������}�Zt0��.0������H3�m����E�l6]l�Si��ï��f(v� 0�-�fb�^a�Hd���	�;N���y0;�O��_Pfb������E��`&&�c�e^��Ifbrv�a&��x0�ܙ��So��Ď �R����~�����f&Ǎ&/���Bfb��a���`~J/KKn��ܬa0C-J�}ײ5��� ��e|3�L���8f O��6#1�!���}f&��b�9���`&v�i��ut��|�i��,fbg�0�3��>��I�F������O��E�䚠Q��W C�GU�L��M%�ۅM�4�+�[c[���Feb�=PB?hjC�بL���8�j�:ojT&v�����X�L���#7�:o���A����r����V����/�8*�[������ިPL�1�����A7o� ��tɃ�@8E��J��{jJp��j�bzO����_=F�b�=!���Z���s1#�������)@\�8_���Ӊ������=��ɇ���Ď��y�i�LL�^"�;sR:9*;m���;��W&v��g7ԍ��d�������ᅶ�V@Geb��(J����;�sU��LLo�څI3�1�21�5خ�Cj����' �ػ��(���NW��%�qN��HLoA ����9��}
"�����Q���!<��ھx�U(vy@v�$�]��f����v� 2C�bG�f�ON�1*K�9$�EM2�R�h�$��cG�b�z����mw:aiT(v���yBĨPL�t���R�bz���m�$�U@���n�*�h�R1M`bf>B�J��"�<b�5�r1*ӋdP{��7���ɠ8��1��R1�"�-�D3G�bz�� 6>�~T(�$`�v�B1��C1��٪r1���1C��BQ��s�r�_��:��)�=zfv�ŠG���
���ƳC��J��=O[�i�LC�3���y��pj�5*0�/��LS����e���z������
�Wf�ev��/�hI@��h�x#Ӭ��F�cjX���n��^�h�S=+/��]Gf����fV^f7�����}�g�e)�,��j��`V^f7�����%^��2��5���@����@3�m;��*`K��^af�nV`f��,��a3#	^���tÖ��gf�gwH����`V^fߞ��c\C6+/��.��7Z��f�ev{�b�|5Ɛ�3��u&��T=;+0�oAo|C�"~C+0�[Ћ25��Hf����ᕺp��`3T`�7�G�	5�?�A�q)oK���m>�Lo��U`�u'(a���zV`��y)^7�v�����4�k��
����n mQ�;+0�o�t�   ��FkEf~�E�]w��*2��Hsk/:����.��}�y���=�/[,L'F0+3�o�K�,���S���o�K�$��fef�=+б����fef�m{�>��E˳23�m/ef_	~E+3�o����h?+3�۔�*�DJZfef�=�0<_�\�4+3��q�Xq޿1+3����e^�B����۔���x�Y��ߦ�1I��<MWf�)%�B�x�li�]��#����,�G9_Z������!i�\��*2;�\�F�A�׬��X]���REf_A�V���̊�����XF"��7�23�g*bN�{P-Ϭ����8�W&0+3�ˏP�����_v��/���x:���ruq�G��Y��dI�����23��;���/��*3�� :z���"3��n�e�S�E�Y���f7bYzJg�̊̾L��N�"���Mly�c���M�B߾I���"3O|$�`�Ǥ^���-1�sМx�J�B�o�k4̧u�Y������W��'��\��~}���չ�9���W����V۰V��h`����ݶ�׫��o2��g7���Y�t��D��=`gElGpzK�B�Y�߭�huә��J����Ÿ���<T+a�-eW3^'����M�pr�_T	��ܫ��J���v$��$ ;C���u*t���ݜ7�����y��q��Fk����y��3͚��?�B�뤸Y���D1T]h1rV�6nphG�n����q�C��p-*_����cҹ�{V�6nKt��c6�����%zL�B+����q�I����qdV�6��g{��aO%i㞆��/��g%i�n��D^�!C%i##�L�"��]Aڸ-����淧��q�U4\�9(O_��A�U�s�UIڸ�*B�pa4��J�ƍVq��CEX���q�ϦX��`������=�?[�����m�iث��qb!�M޹�*I��:N�24Z#���'��F�,xY��6�>���J��=�;D%>�n���q���W�\E��$m�x�1@i,U�6n5\̸Q��J�Ʒ�P�noB��VEiG`GTDgU�6n��x��'n���,r��G��U9ڸǸ��
?"2���2t�QUA�h�v�V��E~uU�6n���E�KqҪm�z��"h`?�*F��-[w��_�V>�E���3W�hG��*1���S1ڸ�s��U)ڸ7:R.l[������s>�V�h)��"XYF�FV�h�Bb,i�%�s�h�ۓ���I��v5���pU�vY����(�U)ڸ�4t6vܕ�A�La���ժ�+�I��_��m|A7�B��/K���D�ɓU�h�qTH�hI��
�fr����p
W�h���'��R��*D��/,jg��C����f�,`U�6/��$�#o��B�y[Ey%���$���g`�[�A�n�N�Rת-��$���.V�h󞽔�>�u�
��e�p{�*��P!ڼ1w�{��
�捹��Z��U!���H�H�O�^��?'�D�'�Ʋ*D�7v�.�H}(WZ���a�CoNDiU�6��4��(�Y��������p2����bS�r�U)ڼ{%Q������R���8�1�X���ݒB��,}6��e�G�Y1���}:��\����\Bs.�*F;�}�^r^7]�� [:��p�\�r�#�� ���V�hGp�X��2$�mރQr��b:�j�������x�Ъ\lރQ�3A�@��XlރQ��p�S����s�n������Ŏ �%��į��R`��>�J+��r�#�.q9�qY����I*1a���=��XQ:��*�`��B�w��*x��ܯ	t@O����{s�8�.Ǡ�A.����Idi�J���U=U@��S���%���v)��MUY�q|@�r, K�η!@��4Y��X�1��_�ͻ#]�"��űU���reC��d/S��ʓ^G��hd��+[ߓ^w:�,���#����a��)��q�k��9����ۚ��,S�ٹ>7�ȔG�_�ٺ%��W{�����?5�^�����#���JaWb��翢@�8#ߕ��{�+�L��4i�J��=�Ս�hְ+1;,F���۱�J�֭�P����&�+1[߭&y�Ʀ��]�ٺG�bے:׌�J���Ċ&l�yWb��g�bs�����p>��2y-rWb�n�V��E�:�v%f�bjJr\�+1[�֪(�4&���#�.�L��R%fG�Gew1^�ڕ��{(m�]N���l��k��rJ*vef��ݘ*Q�C^cWh�.W���9��]�Y
��A�NQ׮�l�U�\��7]�ٺ��hH��h�
;�<2��.�]������%����K�t�i5�����=W/�tq�Ӯ�,g3؜2i�Ʈ��v6Hʀ�dhd���MJ�w�f)��~�xdTjv٘gC��*5K����(i}dWj�r�F���e��C�fG�}�Q�M�uWj�rW�=�t?�P�����5Q*�ڕ���ڙ27,x�Ө�l})����T�+5[�W?�ݛz���R u�1�����֭��.�NIŮ�l}��0�(�+5[�-�1����J͎ ��ؒ�*4;�g0P�]�ٺ[�Q�����g3gP��6s��4��3>�yWh��RA~ØDFv�f���=��ڣ�
��w�`�/<�Whv�]H�n�r+4[��4�J媻B�u���71���$���R��S���p\�$��+4KA���[������hĖQ4[a���Au�z<����58��r�]�پz[N��P+2�R�ťջ"�� ��g�$z?+2;��7�1�P}���l������ɍ�wEf���D���wEf)8�y3�q�~vEf���h<�nx�����?���۲�      u      x������ � �      �      x������ � �      Z      x������ � �      W      x������ � �      o      x������ � �      q      x������ � �      e      x������ � �      c      x������ � �      i      x������ � �      {      x������ � �      m      x������ � �      �      x������ � �      �      x������ � �      y      x������ � �      w      x������ � �      �      x������ � �      [      x������ � �      a      x������ � �      _      x������ � �      ]      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �            x������ � �      g      x������ � �      k      x������ � �      �      x������ � �      }      x������ � �      C      x�3䬨���5SF`2F��� O��      D      x�3,�,O-�2���*/*Q1z\\\ Pw�      X   �   x�}��n� D�������^��V	a�ثbv�.�ܯ�Ӥ��&\�yhfH/�&����\�FL_FpHS��3"À����������Б&0���3�ūQ�M��ҭ�[�����Fuݲ�#�.���Z���|�����~pǊ+�v(�o����1�3���-SD?W�e3��`��"9�Hſ^L�!]�{cWt�>��v!��^9��d`r�Ȗ��0R\~����7��A����!�:[O���iڶ=�mn      s      x������ � �     