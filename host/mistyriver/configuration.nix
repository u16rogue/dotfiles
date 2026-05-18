{ config, lib, modulesPath, pkgs, ... }:

{
    imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    # TODO: configs should use these values to
    # build themself
    #custom-host-state = {
    #    impermanent = {
    #        enabled = true;
    #        path = "/persist";
    #    };
    #    monitor-setup = [
    #        {
    #            name = "DP-3";
    #            position = 2; # on the right
    #            priority = 1; # is the main monitor
    #        }
    #        {
    #            name = "HDMI-A-5";
    #            position = 1; # on the left
    #            priority = 2; # is the 2nd monitor
    #        }
    #    ];
    #};

    boot = {
        kernelModules = [ "kvm-amd" ];

        loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
        };

        initrd = {
            availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
            kernelModules = [ "cryptd" ];
            luks.devices."persist-luks".device = "/dev/disk/by-label/persist-luks";
        };

        swraid = {
            enable = true;
            mdadmConf = "MAILADDR user@example.com"; # prevents mdadm from supposedly crashing
        };
    };

    fileSystems = {
        "/boot" = {
            device = "/dev/disk/by-label/boot";
            fsType = "vfat";
            options = [ "fmask=0077" "dmask=0077" ];
        };

        "/" = {
            device = "none";
            fsType = "tmpfs";
            options = [ "defaults" "size=2G" "mode=755" ];
        };

        "/persist" = {
            depends = [ "/" ];
            neededForBoot = true;
            device = "/dev/disk/by-label/persist";
            fsType = "ext4";
        };

        "/nix" = {
            depends = [ "/persist" ];
            device = "/persist/nix";
            fsType = "none";
            options = [ "bind" ]; # "fmask=002" "dmask=002" 
        };

        "/var/log" = {
            depends = [ "/persist" ];
            device = "/persist/var/log";
            fsType = "none";
            options = [ "bind" ];
        };
    };

    hardware = {
        graphics.enable = true;
        nvidia = {
            modesetting.enable = true;
            open = true;
            package = config.boot.kernelPackages.nvidiaPackages.latest;
        };
        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };

    networking = {
        hostName = "mistyriver";
        networkmanager.enable = true;
        firewall.enable = true;
    };

    services = {
        # TODO: move to common as `pipewire` is present for all host and not hw specific
        pipewire = {
            enable = true;
            pulse.enable = true;
        };
        xserver.videoDrivers = [ "nvidia" ];
    };

    environment = {
        etc = {
            "machine-id".source = "/persist/etc/machine-id";
            "ssh/ssh_host_rsa_key".source = "/persist/etc/ssh/ssh_host_rsa_key";
            "ssh/ssh_host_rsa_key.pub".source = "/persist/etc/ssh/ssh_host_rsa_key.pub";
            "ssh/ssh_host_ed25519_key".source = "/persist/etc/ssh/ssh_host_ed25519_key";
            "ssh/ssh_host_ed25519_key.pub".source = "/persist/etc/ssh/ssh_host_ed25519_key.pub";
        };

        systemPackages = with pkgs; [
            asusctl
        ];
    };

    time.timeZone = "Asia/Taipei"; # :)

    system.stateVersion = "25.11";
}
