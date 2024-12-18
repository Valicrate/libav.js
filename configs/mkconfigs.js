#!/usr/bin/env node
/*
 * Copyright (C) 2021-2024 Yahweasel and contributors
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
 * OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

const cproc = require("child_process");
const fs = require("fs");

const opus = ["parser-opus", "codec-libopus"];
const flac = ["format-flac", "parser-flac", "codec-flac"];
const mp3 = ["format-mp3", "decoder-mp3", "encoder-libmp3lame"];
const vp8 = ["parser-vp8", "codec-libvpx_vp8"];
const vp9 = ["parser-vp9", "codec-libvpx_vp9"];
// Hopefully, a faster AV1 encoder will become an option soon...
const aomav1 = ["parser-av1", "codec-libaom_av1"];
const aomsvtav1 = ["parser-av1", "decoder-libaom_av1", "encoder-libsvtav1"];

// Misanthropic Patent Extortion Gang (formats/codecs by reprobates)
const aac = ["parser-aac", "codec-aac"];
const h264 = ["parser-h264", "decoder-h264", "codec-libopenh264"];
const hevc = ["parser-hevc", "decoder-hevc"];

// Demux and mux list
// removed "format-hls" since I don't need to mux it
const formats = ["format-mp4", "format-webm", "format-matroska", "format-avi"];

// demuxer-3gp not need, included in -mov | demuxer-mpeg doesn't match anything, changed to demuxer-mpegps, nor does demuxer-ipod (it's only a muxer for m4a)
// removed demuxer-dash as we also need to include libxml2 and we aren't going to receive any streams over http to demux
// Demuxers list
const dmux = [
  "demuxer-asf",
  "demuxer-flv",
  "demuxer-hls",
  "demuxer-mov",
  "demuxer-mp4",
  "demuxer-mpegts",
  "demuxer-mpegps",
  "demuxer-rawvideo",
  "demuxer-ogg",
  "demuxer-matroska",
  "demuxer-avi",
  "demuxer-webm",
  "demuxer-dhav",
  "demuxer-dv",
  "demuxer-m4v",
  "parser-mpegvideo",
];

// Video Decoders and parsers list
const vdecpar = [
  "bsf-chomp",
  "parser-vp8",
  "parser-vp9",
  "parser-av1",
  "parser-h264",
  "parser-hevc",
  "bsf-extract_extradata",
  "bsf-vp9_metadata",
  "bsf-av1_metadata",
  "bsf-h264_metadata",
  "bsf-hevc_metadata",
  "decoder-cinepak",
  "decoder-dvvideo",
  "decoder-flv",
  "decoder-h261",
  "parser-h261",
  "decoder-h263",
  "parser-h263",
  "decoder-h263i",
  "decoder-h263p",
  "decoder-mpeg1video",
  "decoder-mpeg2video",
  "bsf-mpeg2_metadata",
  "decoder-mpegvideo",
  "parser-mpegvideo",
  "decoder-mpeg4",
  "bsf-mpeg4_unpack_bframes",
  "bsf-h264_mp4toannexb",
  "bsf-hevc_mp4toannexb",
  "bsf-h264_redundant_pps",
  "bsf-null",
  "bsf-setts",
  "parser-mpeg4video",
  "decoder-msmpeg4v1",
  "decoder-msmpeg4v2",
  "decoder-msmpeg4v3",
  "decoder-msvideo1",
  "decoder-prores",
  "bsf-prores_metadata",
  "decoder-rawvideo",
  "decoder-theora",
  "decoder-vp6",
  "parser-vc1",
  "parser-vp3",
  "decoder-wmv1",
  "decoder-wmv2",
  "decoder-wmv3",
];

// Audio Decoders and parsers list
const adecpar = [
  "parser-ftr",
  "parser-adx",
  "parser-mlp",
  "format-aac",
  "parser-aac",
  "parser-aac_latm",
  "bsf-aac_adtstoasc",
  "codec-aac",
  "parser-opus",
  "codec-libopus",
  "format-flac",
  "parser-flac",
  "codec-flac",
  "format-mp3",
  "decoder-mp3",
  "format-pcm_f32le",
  "codec-pcm_f32le",
  "codec-prores",
  "codec-qtrle",
  "format-wav",
  "codec-libvorbis",
  "codec-alac",
  "decoder-ac3",
  "parser-ac3",
  "decoder-dolby_e",
  "parser-dolby_e",
  "decoder-eac3",
  "bsf-eac3_core",
  "decoder-dvaudio",
  "parser-dvaudio",
  "decoder-dca",
  "parser-dca",
  "bsf-dca_core",
  "bsf-dovi_rpu",
  "bsf-truehd_core",
  "decoder-mp1",
  "parser-mpegaudio",
  "decoder-mp2",
  "decoder-pcm_dvd",
  "decoder-pcm_bluray",
  "decoder-pcm_s16le",
  "decoder-pcm_s24le",
  "decoder-wmav1",
  "decoder-wmav2",
  "decoder-wmapro",
  "decoder-wmavoice",
  "parser-xma",
];

// Video encoders list
// removed "encoder-h263" and "encoder-h263p", both in favor of "codec-mpeg4" to encode H.263 with mpeg4 in the form of DivX
// removed "codec-vnull"
const videnc = ["codec-mpeg4"];

// Audio encoders list
//removed "codec-anull"
const audenc = ["encoder-libmp3lame"];

// Muxers lists
const mux = ["muxer-ipod"];

// Filters list
const avfilt = ["audio-filters", "video-filters", "protocol-jsfetch"];

const configsRaw = [
  // Audio sensible:
  [
    "default",
    [
      "format-ogg",
      "format-webm",
      opus,
      flac,
      "format-wav",
      "codec-pcm_f32le",
      "audio-filters",
    ],
    { cli: true },
  ],

  ["opus", ["format-ogg", "format-webm", opus], { af: true }],
  ["flac", ["format-ogg", flac], { af: true }],
  ["wav", ["format-wav", "codec-pcm_f32le"], { af: true }],

  // Audio silly:
  [
    "obsolete",
    [
      // Modern:
      "format-ogg",
      "format-webm",
      opus,
      flac,

      // Timeless:
      "format-wav",
      "codec-pcm_f32le",

      // Obsolete:
      "codec-libvorbis",
      mp3,

      // (and filters)
      "audio-filters",
    ],
  ],

  // Audio reprobate:
  ["aac", ["format-mp4", "format-aac", "format-webm", aac], { af: true }],

  // Video sensible:
  [
    "webm",
    [
      "format-ogg",
      "format-webm",
      opus,
      flac,
      "format-wav",
      "codec-pcm_f32le",
      "audio-filters",

      "libvpx",
      vp8,
      "swscale",
      "video-filters",
    ],
    { vp9: true, cli: true },
  ],

  [
    "vp8-opus",
    ["format-ogg", "format-webm", opus, "libvpx", vp8],
    { avf: true },
  ],
  [
    "vp9-opus",
    ["format-ogg", "format-webm", opus, "libvpx", vp9],
    { avf: true },
  ],
  ["av1-opus", ["format-ogg", "format-webm", opus, aomav1], { avf: true }],

  // Video reprobate:
  [
    "h264-aac",
    ["format-mp4", "format-aac", "format-webm", aac, h264],
    { avf: true },
  ],
  [
    "hevc-aac",
    ["format-mp4", "format-aac", "format-webm", aac, hevc],
    { avf: true },
  ],

  // Mostly parsing:
  [
    "webcodecs",
    [
      "format-ogg",
      "format-webm",
      "format-mp4",
      opus,
      flac,
      "format-wav",
      "codec-pcm_f32le",
      "parser-aac",

      "parser-vp8",
      "parser-vp9",
      "parser-av1",
      "parser-h264",
      "parser-hevc",

      "bsf-extract_extradata",
      "bsf-vp9_metadata",
      "bsf-av1_metadata",
      "bsf-h264_metadata",
      "bsf-hevc_metadata",
    ],
    { avf: true },
  ],

  // These are here so that "all" will have them for testing
  [
    "extras",
    [
      // Images
      "format-image2",
      "demuxer-image_gif_pipe",
      "demuxer-image_jpeg_pipe",
      "demuxer-image_png_pipe",
      "parser-gif",
      "codec-gif",
      "parser-mjpeg",
      "codec-mjpeg",
      "parser-png",
      "codec-png",
      "parser-webp",
      "decoder-webp",

      // Raw data
      "format-rawvideo",
      "codec-rawvideo",
      "format-pcm_f32le",
      "codec-pcm_f32le",

      // Apple-flavored lossless
      "codec-alac",
      "codec-prores",
      "codec-qtrle",

      // HLS
      "format-hls",
      "protocol-jsfetch",
    ],
  ],

  // The set of options for Sink
  [
    "sink",
    [
      "swscale",
      formats,
      dmux,
      mux,
      vdecpar,
      adecpar,
      videnc,
      audenc,
      avfilt,
      "workerfs",
      "cli",
    ],
  ],

  ["empty", []],
  ["all", null],
];
let all = Object.create(null);

function configGroup(configs, nameExt, parts) {
  const toAdd = configs.map((config) => [
    `${config[0]}-${nameExt}`,
    config[1].concat(parts),
  ]);
  configs.push.apply(configs, toAdd);
}

// Process the configs into groups
const configs = [];
for (const config of configsRaw) {
  const [name, inParts, extra] = config;

  // Expand the parts
  const parts = inParts ? [] : null;
  if (inParts) {
    for (const part of inParts) {
      if (part instanceof Array) parts.push.apply(parts, part);
      else parts.push(part);
    }
  }

  // Expand the extras
  const toAdd = [[name, parts]];
  if (extra && extra.vp9) configGroup(toAdd, "vp9", vp9);
  if (extra && extra.af) configGroup(toAdd, "af", ["audio-filters"]);
  if (extra && extra.avf)
    configGroup(toAdd, "avf", ["audio-filters", "swscale", "video-filters"]);
  if (extra && extra.cli) configGroup(toAdd, "cli", ["cli"]);

  configs.push.apply(configs, toAdd);
}

// Process arguments
let createOnes = false;
for (const arg of process.argv.slice(2)) {
  if (arg === "--create-ones") createOnes = true;
  else {
    console.error(`Unrecognized argument ${arg}`);
    process.exit(1);
  }
}

async function main() {
  for (let [name, config] of configs) {
    if (name !== "all") {
      for (const fragment of config) all[fragment] = true;
    } else {
      config = Object.keys(all);
    }

    const p = cproc.spawn("./mkconfig.js", [name, JSON.stringify(config)], {
      stdio: "inherit",
    });
    await new Promise((res) => p.on("close", res));
  }

  if (createOnes) {
    const allFragments = Object.keys(all)
      .map((x) => {
        // Split up codecs and formats
        const p = /^([^-]*)-(.*)$/.exec(x);
        if (!p) return [x];
        if (p[1] === "codec") return [`decoder-${p[2]}`, `encoder-${p[2]}`, x];
        else if (p[1] === "format")
          return [`demuxer-${p[2]}`, `muxer-${p[2]}`, x];
        else return [x];
      })
      .reduce((a, b) => a.concat(b));

    for (const fragment of allFragments) {
      // Fix fragment dependencies
      let fragments = [fragment];
      if (fragment.indexOf("libvpx") >= 0) fragments.unshift("libvpx");
      if (fragment === "parser-aac") fragments.push("parser-ac3");

      // And make the variant
      const p = cproc.spawn(
        "./mkconfig.js",
        [`one-${fragment}`, JSON.stringify(fragments)],
        { stdio: "inherit" }
      );
      await new Promise((res) => p.on("close", res));
    }
  }
}
main();
