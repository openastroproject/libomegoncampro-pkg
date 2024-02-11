%define debug_package %{nil}

Name:           libomegonprocam
Version:        1.55.24621
Release:        1
Summary:        Omegon camera support libraries
License:	GPLv2+
URL:            http://www.omegon.eu/
Prefix:         %{_prefix}
Provides:       libomegonprocam = %{version}-%{release}
Obsoletes:      libomegonprocam < 1.55.24621
Source:         libomegonprocam-%{version}.tar.gz
Patch0:         pkg-config.patch
Patch1:         udev-rules.patch

%description
libomegonprocam is a user-space driver for Omegon astronomy cameras.

%package        devel
Summary:        Development files for %{name}
Group:          Development/Libraries
Requires:       %{name}%{?_isa} = %{version}-%{release}
Provides:       libomegonprocam-devel = %{version}-%{release}
Obsoletes:      libomegonprocam-devel < 1.55.24621

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%prep
%setup -q
%patch0 -p0
%patch1 -p0

%build

sed -e "s!@LIBDIR@!%{_libdir}!g" -e "s!@VERSION@!%{version}!g" < \
    libomegonprocam.pc.in > libomegonprocam.pc

%install
mkdir -p %{buildroot}%{_libdir}/pkgconfig
mkdir -p %{buildroot}%{_includedir}
mkdir -p %{buildroot}%{_docdir}/%{name}-%{version}
mkdir -p %{buildroot}%{_udevrulesdir}

case %{_arch} in
  x86_64)
    cp linux/x64/libomegonprocam.so %{buildroot}%{_libdir}/libomegonprocam.so.%{version}
    ;;
  *)
    echo "unknown target architecture %{_arch}"
    exit 1
    ;;
esac

ln -sf %{name}.so.%{version} %{buildroot}%{_libdir}/%{name}.so.1
cp inc/*.h %{buildroot}%{_includedir}
cp *.pc %{buildroot}%{_libdir}/pkgconfig
cp doc/* %{buildroot}%{_docdir}/%{name}-%{version}
cp 70-omegonpro-cameras.rules %{buildroot}%{_udevrulesdir}

%post
/sbin/ldconfig
/sbin/udevadm control --reload-rules

%postun
/sbin/ldconfig
/sbin/udevadm control --reload-rules

%files
%{_libdir}/*.so.*
%{_udevrulesdir}/*.rules

%files devel
%{_includedir}/omegonprocam*.h
%{_libdir}/pkgconfig/%{name}*.pc
%{_docdir}/%{name}-%{version}/*.html

%changelog
* Sat Feb 10 2024 James Fidell <james@openastroproject.org> - 1.55.24621-1
- Update from upstream
* Fri Jan 5 2024 James Fidell <james@openastroproject.org> - 1.55.24239-1
- Update from upstream
* Sun Jun 7 2020 James Fidell <james@openastroproject.org> - 1.39.15325-1
- Initial RPM release
