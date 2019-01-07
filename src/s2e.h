// Copyright (C) 2016-2019 Semtech (International) AG. All rights reserved.
//
// This file is subject to the terms and conditions defined in file 'LICENSE',
// which is part of this source code package.

#ifndef _s2e_h_
#define _s2e_h_

#include "s2conf.h"
#include "sys.h"
#include "uj.h"
#include "xq.h"
#include "ws.h"

extern uL_t* s2e_joineuiFilter;
extern u4_t  s2e_netidFilter[4];
int s2e_parse_lora_frame(ujbuf_t* buf, const u1_t* frame , int len, dbuf_t* lbuf);


enum { SF12, SF11, SF10, SF9, SF8, SF7, FSK, SFNIL };
enum { BW125, BW250, BW500, BWNIL };
enum { RPS_DNONLY = 0x20 };
enum { RPS_BCN = 0x40 };
enum { RPS_ILLEGAL = 0xFF };
enum { RPS_FSK = FSK };
typedef u1_t rps_t;
inline int   rps_sf   (rps_t params) { return params &  0x7; }
inline int   rps_bw   (rps_t params) { return (params >> 3) & 0x3; }
inline rps_t rps_make (int sf, int bw) { return (sf&7) | ((bw&3)<<3); }

// Radio TX states
enum {
    TXSTATUS_IDLE,
    TXSTATUS_SCHEDULED,
    TXSTATUS_EMITTING,
};

// Modes for txjobs
enum {
    TXFLAG_TXING     = 0x01,
    TXFLAG_TXCHECKED = 0x02,
    TXFLAG_CLSA      = 0x04,
    TXFLAG_PING      = 0x08,
    TXFLAG_CLSC      = 0x10,
    TXFLAG_BCN       = 0x20,  
};


enum {
    TXCOND_CANTX = 0, // can send without restriction
    TXCOND_CCA,       // can send only if channel clear
    TXCOND_NOCA,      // no channel access
    TXCOND_NODC,      // definitely no DC
};

enum { PRIO_PENALTY_ALTTXTIME  = 10 };
enum { PRIO_PENALTY_ALTANTENNA = 10 };
enum { PRIO_PENALTY_CCA        =  8 };



enum { DC_DECI, DC_CENTI, DC_MILLI, DC_NUM_BANDS };
enum { MAX_DNCHNLS = 48 };
enum { DR_CNT = 16 };
enum { DR_ILLEGAL = 16 };

typedef struct s2txunit {
    ustime_t dc_eu863bands[DC_NUM_BANDS];
    ustime_t dc_perChnl[MAX_DNCHNLS+1];
    txidx_t  head;
    tmr_t    timer;
} s2txunit_t;

typedef struct s2ctx {
    dbuf_t (*getSendbuf) (struct s2ctx* s2ctx, int minsize);     // wired to TC/websocket
    void   (*sendText)   (struct s2ctx* s2ctx, dbuf_t* buf);     // ditto
    void   (*sendBinary) (struct s2ctx* s2ctx, dbuf_t* buf);     // ditto
    int    (*canTx)      (struct s2ctx* s2ctx, txjob_t* txjob, int* ccaDisabled);  // region dependent

    u1_t     ccaEnabled;     // this region uses CCA
    rps_t    dr_defs[DR_CNT];
    u2_t     dc_chnlRate;
    u4_t     dn_chnls[MAX_DNCHNLS+1];
    u4_t     min_freq;
    u4_t     max_freq;
    s2_t     txpow;          // default TX power
    s2_t     txpow2;         // special TX power for range / 0 = does not apply
    u4_t     txpow2_freq[2]; // freq range for txpow2      / 0,0 = no range
    ujcrc_t  region;
    char     region_s[16];
    txq_t    txq;
    rxq_t    rxq;
    double   muxtime;    // time stamp from muxs
    ustime_t reftime;    // local time at arrival of muxtime
    s2txunit_t txunits[MAX_TXUNITS];

} s2ctx_t;


// Global switches to enable/disable certain features (accross TC sessions)
// (also interactively - without resetting/changing parameters)
extern u1_t s2e_dcDisabled;    // ignore duty cycle limits - override for test/dev
extern u1_t s2e_ccaDisabled;   // ignore busy channels - override for test/dev
extern u1_t s2e_dwellDisabled; // ignore dwell time limits - override for test/dev


rps_t    s2e_dr2rps (s2ctx_t*, u1_t dr);
u1_t     s2e_rps2dr (s2ctx_t*, rps_t rps);
ustime_t s2e_calcUpAirTime (rps_t rps, u1_t plen);
ustime_t s2e_calcDnAirTime (rps_t rps, u1_t plen);
ustime_t s2e_updateMuxtime(s2ctx_t* s2ctx, double muxstime, ustime_t now);   // now=0 => rt_getTime(), return now

void     s2e_ini          (s2ctx_t*);
void     s2e_free         (s2ctx_t*);
void     s2e_enableDC     (s2ctx_t*, u2_t chnlRate);
void     s2e_disableDC    (s2ctx_t*);
rxjob_t* s2e_nextRxjob    (s2ctx_t*);
void     s2e_addRxjob     (s2ctx_t*, rxjob_t* rxjob);
void     s2e_flushRxjobs  (s2ctx_t*);
int      s2e_onMsg        (s2ctx_t*, char* json, ujoff_t jsonlen);
int      s2e_onBinary     (s2ctx_t*, u1_t* data, ujoff_t datalen);
ustime_t s2e_nextTxAction (s2ctx_t*, u1_t txunit);
int      s2e_handleCommands (ujcrc_t msgtype, s2ctx_t* s2ctx, ujdec_t* D);
void     s2e_handleRmtsh    (s2ctx_t* s2ctx, ujdec_t* D);


#endif // _s2e_h_