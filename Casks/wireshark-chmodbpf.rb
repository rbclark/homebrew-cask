cask 'wireshark-chmodbpf' do
  version '2.6.6'
  sha256 '71920bf98e2867703759b0c98395480f88dee1c332efd3f2bc6a91eaec75b0a3'

  url "https://www.wireshark.org/download/osx/Wireshark%20#{version}%20Intel%2064.dmg"
  appcast 'https://www.wireshark.org/download/osx/'
  name 'Wireshark-ChmodBPF'
  homepage 'https://www.wireshark.org/'

  conflicts_with cask: 'wireshark'

  pkg "Wireshark #{version} Intel 64.pkg",
      choices: [
                 {
                   'choiceIdentifier' => 'wireshark',
                   'choiceAttribute'  => 'selected',
                   'attributeSetting' => 0,
                 },
                 {
                   'choiceIdentifier' => 'chmodbpf',
                   'choiceAttribute'  => 'selected',
                   'attributeSetting' => 1,
                 },
                 {
                   'choiceIdentifier' => 'cli',
                   'choiceAttribute'  => 'selected',
                   'attributeSetting' => 0,
                 },
               ]

  uninstall_preflight do
    set_ownership '/Library/Application Support/Wireshark'
  end

  uninstall pkgutil:   'org.wireshark.ChmodBPF.pkg',
            launchctl: 'org.wireshark.ChmodBPF',
            script:    {
                         executable:   '/usr/sbin/dseditgroup',
                         args:         ['-o', 'delete', 'access_bpf'],
                         must_succeed: false,
                         sudo:         true,
                       }

  caveats do
    reboot
    <<~EOS
      This cask will install only the ChmodBPF package from the current Wireshark
      stable install package.
      An access_bpf group will be created and its members allowed access to BPF
      devices at boot to allow unprivileged packet captures.
      This cask is not required if installing the Wireshark cask. It is meant to
      support Wireshark installed from Homebrew or other cases where unprivileged
      access to macOS packet capture devices is desired without installing the binary
      distribution of Wireshark.
      The user account used to install this cask will be added to the access_bpf
      group automatically.
    EOS
  end
end
