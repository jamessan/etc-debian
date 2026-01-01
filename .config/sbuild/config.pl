# Directory for writing build logs to
$log_dir = "$HOME/.cache/sbuild/logs";
$source_only_changes = 1;
$chroot_mode = 'unshare';

$unshare_tmpdir_template = '/dev/shm/tmp.sbuild.XXXXXXXXXX';
$unshare_bind_mounts = [ { directory => "$HOME/.cache/ccache", mountpoint => "/build/ccache" }, { directory => "$HOME/src/debian.org/debcargo", mountpoint => "$HOME/src/debian.org/debcargo" } ];
$unshare_mmdebstrap_keep_tarball = 1;
$unshare_mmdebstrap_env_cmd = [ 'env', 'TMPDIR=/dev/shm/' ];
$unshare_mmdebstrap_extra_args = [
	'*' => ['--include=debhelper', q#--aptopt='Acquire::http { Proxy "http://127.0.0.1:3142"; }'#, "$HOME/.config/sbuild/%r.sources"],
	'debcargo-%r-%a-sbuild' => ['--include=dh-cargo,cargo'],
	'stable-backports' => [
		'--setup-hook=echo "deb http://deb.debian.org/debian stable-backports main" > "$1"/etc/apt/sources.list.d/stable-backports.list',
		'--setup-hook=echo "deb-src http://deb.debian.org/debian stable-backports main" >> "$1"/etc/apt/sources.list.d/stable-backports.list',
	]
];

$aspcud_criteria = '-count(down),-count(solution,APT-Release:=/experimental/),-removed,-changed,-new';

$build_environment = { "CCACHE_DIR" => "/build/ccache" };
$path = "/usr/lib/ccache:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games";
$build_path = "/build/package/";
$dsc_dir = "package";
$autopkgtest_opts = [ '--apt-upgrade', '--env=CCACHE_DIR=/build/ccache', '--env=PATH=/usr/lib/ccache:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games' ];
$autopkgtest_virt_server_options = [ '--tarball', "$HOME/.cache/sbuild/%r-%a-sbuild.tar.xz", '--prefix=/dev/shm/tmp.autopkgtest.', '--bind', "$HOME/.cache/ccache", '/build/ccache' ];
$autopkgtest_virt_server = 'autopkgtest-virt-unshare';

use Dpkg::BuildInfo;

$environment_filter = [
	Dpkg::BuildInfo::get_build_env_allowed(),
	'^DEB(IAN|SIGN)?_[A-Z_]+$',
	# debhelper
	'^DH_[A-Z_]+$',
	'^CARGO_[A-Z_]+$',
	# devscripts
	'^DEB(EMAIL|FULLNAME)$',
	'^(C(PP|XX)?|LD|F)FLAGS_APPEND$',
];

$run_lintian = 1;
$lintian_opts = [
	'--color=auto',
	'--info',
	'--display-experimental',
	'--display-level', '>=pedantic',
];

# don't remove this, Perl needs it:
1;
