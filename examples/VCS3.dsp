import("seam.lib");

process = svc.vcs3osc1(svc.freq1,svc.shape1,svc.samp1,svc.pamp1),
          svc.vcs3osc2(svc.freq2,svc.shape2,svc.sqamp2,svc.tramp2),
          svc.vcs3osc3(svc.freq3,svc.shape3,svc.sqamp3,svc.tramp3);
