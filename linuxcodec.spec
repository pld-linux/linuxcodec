#
# Conditional build:
%bcond_with	license_agreement	# generates package
#
%define		source_url      http://www2.mplayerhq.hu/MPlayer/releases/codecs/
#
%define		base_name	linuxcodec
Summary:	Binary compression/decompression libraries used by movie players
Summary(pl):	Binarne biblioteki do kompresji/dekompresji dla odtwarzaczy filmów
%if %{with license_agreement}
Name:		%{base_name}
%else
Name:		%{base_name}-installer
%endif
%define		_rel	1
# put latest for any tarball date here
Version:	20061203
Release:	%{_rel}%{?with_license_agreement:wla}
License:	Free for non-commercial use
Group:		Libraries
%if %{with license_agreement}
Source0:	%{source_url}essential-20061022.tar.bz2
Source1:	%{source_url}all-ppc-20061022.tar.bz2
Source2:	%{source_url}essential-amd64-%{version}.tar.bz2
Source3:	%{source_url}all-alpha-20061028.tar.bz2
BuildRequires:	unzip
%else
Source0:	license-installer.sh
Requires:	rpm-build-tools
Requires:	unzip
Provides:	%{base_name}
%endif
AutoReqProv:	no
ExclusiveArch:	%{ix86} %{x8664} alpha ppc
BuildRoot:	%{tmpdir}/%{name}-%{version}-root-%(id -u -n)

%description
Libraries required to compress/decompress content of movie files in
some formats. They are used by movie players, but can be used to
create compressed movie files.

%description -l pl
Biblioteki niezbêdne do kompresji/dekompresji filmów w pewnych
formatach. S± one wykorzystywane przez odtwarzacze, ale mog± byæ u¿yte
do tworzenia kompresowanych plików z filmami.

%prep
%if %{with license_agreement}
%setup -q -c -T
%ifarch %{ix86}
bzcat %{SOURCE0} | tar xf -
%endif
%ifarch ppc
bzcat %{SOURCE1} | tar xf -
%endif
%ifarch %{x8664}
bzcat %{SOURCE2} | tar xf -
%endif
%ifarch alpha
bzcat %{SOURCE3} | tar xf -
%endif
%endif

%install
rm -rf $RPM_BUILD_ROOT

%if %{without license_agreement}
install -d $RPM_BUILD_ROOT{%{_bindir},%{_datadir}/%{base_name}}

sed -e '
	s/@BASE_NAME@/%{base_name}/g
	s/@TARGET_CPU@/%{_target_cpu}/g
	s-@VERSION@-%{version}-g
	s-@RELEASE@-%{release}-g
	s,@SPECFILE@,%{_datadir}/%{base_name}/%{base_name}.spec,g
' %{SOURCE0} > $RPM_BUILD_ROOT%{_bindir}/%{base_name}.install

install %{_specdir}/%{base_name}.spec $RPM_BUILD_ROOT%{_datadir}/%{base_name}

%else
install -d $RPM_BUILD_ROOT%{_libdir}/codecs

# we want only linux codecs here, win one are in w32codec.spec
rm -f essential-[0-9]*/*.{dll,qtx,ax,acm,drv,DLL,qts,vwp}
# intel codecs in ppc package
rm -f all-ppc-[0-9]*/*.xa

install */*.* $RPM_BUILD_ROOT%{_libdir}/codecs
%endif

%if %{without license_agreement}
%post
%{_bindir}/%{base_name}.install
%endif

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%if %{with license_agreement}
%dir %{_libdir}/codecs
%attr(755,root,root) %{_libdir}/codecs/*
%else
%attr(755,root,root) %{_bindir}/linuxcodec.install
%{_datadir}/%{base_name}
%endif
