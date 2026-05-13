#ifndef	__TOUCH_PROBE_h__
#define	__TOUCH_PROBE_h__

extern void TP_Initial(void);
extern void TP_Start(void);
extern void TP_Stop(void);
extern void TP_ChangeCommand(unsigned Command, unsigned Parameter1, unsigned Parameter2);
extern void TP_ServiceLoop(void);

#endif
